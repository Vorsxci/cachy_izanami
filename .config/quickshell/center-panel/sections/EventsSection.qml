import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

// EventsSection — data-only component. Parses calendar.ics and exposes:
//   events:     [{ title, start, end, rawH, rawMin, allDay }]
//   eventDates: ["YYYY-MM-DD", ...]
//   friendlyDate(evt) -> string
// The UI is rendered inline in CenterPanel to avoid duplicate instances.
Item { implicitWidth: 0; implicitHeight: 0
    property var eventDates: []
    property var events:     []

    // ── File loading — one FileView per calendar ─────────────
    // text() is a FUNCTION in Quickshell FileView, not a property.
    // Each FileView stores its last-read text in a property so mergeAndPublish()
    // can combine all three calendars into one sorted list.

    property string _canvasText:   ""
    property string _eventsText:   ""
    property string _meetingsText: ""

    FileView {
        id: canvasCal
        path: "/home/kazuki/.config/quickshell/center-panel/canvasCal"
        watchChanges: true
        onTextChanged: { _canvasText   = canvasCal.text();   mergeAndPublish() }
        onFileChanged: canvasCal.reload()
    }

    FileView {
        id: eventsCal
        path: "/home/kazuki/.config/quickshell/center-panel/eventsCal"
        watchChanges: true
        onTextChanged: { _eventsText   = eventsCal.text();   mergeAndPublish() }
        onFileChanged: eventsCal.reload()
    }

    FileView {
        id: meetingsCal
        path: "/home/kazuki/.config/quickshell/center-panel/meetingsCal"
        watchChanges: true
        onTextChanged: { _meetingsText = meetingsCal.text(); mergeAndPublish() }
        onFileChanged: meetingsCal.reload()
    }

    // ── ICS fetcher — reads each .conf and curls its ICS_URL ────
    Process {
        id: fetchProc
        command: ["bash", "/home/kazuki/.local/bin/fetch-calendars-quickshell"]
        running: true
    }

    Timer {
        interval: 900000   // 15 minutes
        running: true
        repeat: true
        onTriggered: fetchProc.running = true
    }

    Component.onCompleted: {
        _canvasText   = canvasCal.text()
        _eventsText   = eventsCal.text()
        _meetingsText = meetingsCal.text()
        mergeAndPublish()
    }

    // ── Helpers ───────────────────────────────────────────────

    function dateKey(d) {
        var y  = d.getFullYear()
        var mo = d.getMonth() + 1
        var dy = d.getDate()
        return y + "-" + (mo < 10 ? "0" : "") + mo + "-" + (dy < 10 ? "0" : "") + dy
    }

    function propValue(line) {
        var i = line.indexOf(":")
        return i === -1 ? "" : line.substring(i + 1).trim()
    }

    // Extract parameter like TZID from "DTSTART;TZID=America/New_York:20260128T110000"
    function propParam(line, param) {
        var colon = line.indexOf(":")
        if (colon === -1) return ""
        var before   = line.substring(0, colon).toUpperCase()
        var needle   = param.toUpperCase() + "="
        var idx      = before.indexOf(needle)
        if (idx === -1) return ""
        var start    = idx + needle.length
        // Get original-case value from the original line
        var origBefore = line.substring(0, colon)
        var valStart   = idx + needle.length
        var valEnd     = origBefore.indexOf(";", valStart)
        return valEnd === -1 ? origBefore.substring(valStart) : origBefore.substring(valStart, valEnd)
    }

    function isDSTActive(d) {
        var yr       = d.getFullYear()
        var mar      = new Date(yr, 2, 1)
        var dstStart = new Date(yr, 2, (7 - mar.getDay()) % 7 + 8)
        dstStart.setHours(2, 0, 0, 0)
        var nov    = new Date(yr, 10, 1)
        var dstEnd = new Date(yr, 10, (7 - nov.getDay()) % 7 + 1)
        dstEnd.setHours(2, 0, 0, 0)
        return d >= dstStart && d < dstEnd
    }

    function tzOffsetMin(tzid, refLocalDate) {
        if (!tzid) return 0
        var u = tzid.toUpperCase()
        if (u.indexOf("PUERTO_RICO") !== -1) return -240
        if (u.indexOf("NEW_YORK")  !== -1 ||
            u.indexOf("INDIANA")   !== -1 ||
            u.indexOf("EASTERN")   !== -1) {
            return isDSTActive(refLocalDate) ? -240 : -300
        }
        return -refLocalDate.getTimezoneOffset()
    }

    // Returns { utcDate, rawH, rawMin, allDay, tzid } or null
    function parseDt(val, tzid) {
        if (!val || val.length < 8) return null
        var v   = val.trim()
        var y   = parseInt(v.substring(0, 4), 10)
        var mo  = parseInt(v.substring(4, 6), 10) - 1
        var day = parseInt(v.substring(6, 8), 10)
        if (v.length === 8) {
            return { utcDate: new Date(y, mo, day), rawH: 0, rawMin: 0, allDay: true, tzid: tzid || "" }
        }
        var h   = parseInt(v.substring(9,  11), 10)
        var min = parseInt(v.substring(11, 13), 10)
        var sec = v.length >= 15 ? parseInt(v.substring(13, 15), 10) : 0
        var utcDate
        if (v.charAt(v.length - 1) === "Z") {
            utcDate = new Date(Date.UTC(y, mo, day, h, min, sec))
        } else {
            var placeholder = new Date(y, mo, day, h, min, sec)
            var offMin      = tzOffsetMin(tzid, placeholder)
            utcDate = new Date(Date.UTC(y, mo, day, h, min, sec) + offMin * 60000)
        }
        return { utcDate: utcDate, rawH: h, rawMin: min, allDay: false, tzid: tzid || "" }
    }

    function dowToJS(code) {
        var c = code.substring(code.length - 2)
        if (c === "SU") return 0
        if (c === "MO") return 1
        if (c === "TU") return 2
        if (c === "WE") return 3
        if (c === "TH") return 4
        if (c === "FR") return 5
        if (c === "SA") return 6
        return -1
    }

    // expandRrule: returns array of { start, end, rawH, rawMin }
    function expandRrule(rruleStr, masterDt, masterEndDt, exdates, overrides, windowStart, windowEnd) {
        var dtstart = masterDt.utcDate
        var results = []

        if (!rruleStr) {
            if (dtstart >= windowStart && dtstart <= windowEnd)
                results.push({ start: dtstart, end: masterEndDt ? masterEndDt.utcDate : null, rawH: masterDt.rawH, rawMin: masterDt.rawMin })
            return results
        }

        // Parse rrule params into object
        var rparams = {}
        var rparts  = rruleStr.split(";")
        for (var rpi = 0; rpi < rparts.length; rpi++) {
            var eq = rparts[rpi].indexOf("=")
            if (eq !== -1)
                rparams[rparts[rpi].substring(0, eq)] = rparts[rpi].substring(eq + 1)
        }

        if (!rparams["FREQ"] || rparams["FREQ"] !== "WEEKLY") {
            if (dtstart >= windowStart && dtstart <= windowEnd)
                results.push({ start: dtstart, end: masterEndDt ? masterEndDt.utcDate : null, rawH: masterDt.rawH, rawMin: masterDt.rawMin })
            return results
        }

        var targetDows = []
        if (rparams["BYDAY"]) {
            var bydayParts = rparams["BYDAY"].split(",")
            for (var bdi = 0; bdi < bydayParts.length; bdi++) {
                var d = dowToJS(bydayParts[bdi].trim())
                if (d !== -1) targetDows.push(d)
            }
        }
        if (targetDows.length === 0) targetDows.push(dtstart.getUTCDay())

        var interval = rparams["INTERVAL"] ? parseInt(rparams["INTERVAL"], 10) : 1
        var maxCount = rparams["COUNT"]    ? parseInt(rparams["COUNT"],    10) : 9999

        var until = null
        if (rparams["UNTIL"]) {
            var uStr = rparams["UNTIL"].trim()
            if (uStr.charAt(uStr.length - 1) !== "Z") uStr = uStr + "Z"
            var uParsed = parseDt(uStr, null)
            if (uParsed) until = uParsed.utcDate
        }

        var duration = (masterEndDt && masterDt) ? (masterEndDt.utcDate - masterDt.utcDate) : 0

        // Start-of-week (UTC Sunday) containing dtstart
        var weekBase0 = new Date(dtstart)
        weekBase0.setUTCDate(weekBase0.getUTCDate() - weekBase0.getUTCDay())
        weekBase0.setUTCHours(0, 0, 0, 0)

        var hitCount = 0
        for (var w = 0; hitCount < maxCount && w < 500; w += interval) {
            var wb = new Date(weekBase0)
            wb.setUTCDate(weekBase0.getUTCDate() + w * 7)

            if (wb > windowEnd && (!until || wb > until)) break

            for (var di = 0; di < targetDows.length; di++) {
                var dow  = targetDows[di]
                var cand = new Date(wb)
                cand.setUTCDate(wb.getUTCDate() + dow)

                // Set correct UTC time for this occurrence using rawH/rawMin + tz offset
                var candLocal = new Date(cand.getUTCFullYear(), cand.getUTCMonth(), cand.getUTCDate(),
                                         masterDt.rawH, masterDt.rawMin, 0)
                var offMin    = tzOffsetMin(masterDt.tzid, candLocal)
                // offMin is negative west of UTC (e.g. -300 EST), so UTC hour = rawH - offMin/60
                cand.setUTCHours(masterDt.rawH + (offMin / 60), masterDt.rawMin, 0, 0)

                if (cand < dtstart)        continue
                if (until && cand > until) continue
                if (hitCount >= maxCount)  break

                var ck = dateKey(cand)

                // Check EXDATE
                var isEx = false
                for (var ei = 0; ei < exdates.length; ei++) {
                    if (dateKey(exdates[ei].utcDate) === ck) { isEx = true; break }
                }
                if (isEx) { hitCount++; continue }

                // Check override
                var ovr = null
                for (var oi = 0; oi < overrides.length; oi++) {
                    if (overrides[oi].key === ck) { ovr = overrides[oi]; break }
                }
                if (ovr) {
                    if (ovr.start >= windowStart && ovr.start <= windowEnd)
                        results.push({ start: ovr.start, end: ovr.end, rawH: ovr.rawH, rawMin: ovr.rawMin })
                    hitCount++
                    continue
                }

                hitCount++

                if (cand >= windowStart && cand <= windowEnd) {
                    var endDate = duration > 0 ? new Date(cand.getTime() + duration) : null
                    results.push({ start: new Date(cand), end: endDate, rawH: masterDt.rawH, rawMin: masterDt.rawMin })
                }
            }
        }
        return results
    }

    // ── Main parser ───────────────────────────────────────────
    function parseIcs(text, calName) {
        if (!text || text.length === 0) return

        var windowStart = new Date()
        windowStart.setHours(0, 0, 0, 0)
        var windowEnd = new Date(windowStart)
        windowEnd.setDate(windowEnd.getDate() + 90)

        // Unfold lines (join continuation lines starting with space/tab)
        var raw    = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n")
        var folded = raw.split("\n")
        var lines  = []
        for (var fi = 0; fi < folded.length; fi++) {
            var line = folded[fi]
            while (fi + 1 < folded.length &&
                   (folded[fi+1].charAt(0) === " " || folded[fi+1].charAt(0) === "\t")) {
                fi++
                line += folded[fi].substring(1)
            }
            lines.push(line)
        }

        // Parse VEVENT blocks into a flat array of event objects
        // Each entry: { uid, title, dtstart, dtend, rrule, exdates[], overrides[], isOverride, recKey, status }
        // We use an array + uid lookup rather than a plain object to avoid for...in
        var uidIndex = {}   // uid -> index in masters[]
        var masters  = []   // array of master events
        var orphanOverrides = []  // overrides whose master hasn't been seen yet

        var inEvent = false
        var cur     = null

        for (var li = 0; li < lines.length; li++) {
            var ln = lines[li]

            if (ln === "BEGIN:VEVENT") {
                inEvent = true
                cur = { uid: null, title: null, dtstart: null, dtend: null,
                        rrule: null, tzid: "", exdates: [], recurrenceId: null, status: null }
                continue
            }

            if (ln === "END:VEVENT") {
                inEvent = false
                if (!cur || !cur.dtstart) { cur = null; continue }

                if (cur.recurrenceId) {
                    // This is an override for a specific occurrence
                    var ovEntry = {
                        key:    dateKey(cur.recurrenceId.utcDate),
                        start:  cur.dtstart.utcDate,
                        end:    cur.dtend ? cur.dtend.utcDate : null,
                        rawH:   cur.dtstart.rawH,
                        rawMin: cur.dtstart.rawMin
                    }
                    if (cur.uid !== null && uidIndex[cur.uid] !== undefined) {
                        masters[uidIndex[cur.uid]].overrides.push(ovEntry)
                    } else {
                        orphanOverrides.push({ uid: cur.uid, ov: ovEntry })
                    }
                } else {
                    // Master event
                    if (cur.uid !== null && uidIndex[cur.uid] !== undefined) {
                        // Duplicate uid — update master (shouldn't happen but be safe)
                    } else {
                        var masterEntry = {
                            uid:       cur.uid,
                            title:     cur.title || "Untitled",
                            dtstart:   cur.dtstart,
                            dtend:     cur.dtend,
                            rrule:     cur.rrule,
                            exdates:   cur.exdates,
                            overrides: [],
                            status:    cur.status
                        }
                        masters.push(masterEntry)
                        if (cur.uid !== null) uidIndex[cur.uid] = masters.length - 1
                    }
                }
                cur = null
                continue
            }

            if (!inEvent || !cur) continue

            var semi  = ln.indexOf(";")
            var colon = ln.indexOf(":")
            if (colon === -1) continue
            var nameEnd  = (semi !== -1 && semi < colon) ? semi : colon
            var propName = ln.substring(0, nameEnd).toUpperCase()

            if (propName === "UID") {
                cur.uid = propValue(ln)
            } else if (propName === "SUMMARY") {
                cur.title = propValue(ln)
            } else if (propName === "STATUS") {
                cur.status = propValue(ln)
            } else if (propName === "RRULE") {
                cur.rrule = propValue(ln)
            } else if (propName === "DTSTART") {
                var tzid1   = propParam(ln, "TZID")
                var parsed1 = parseDt(propValue(ln), tzid1)
                if (parsed1) { cur.tzid = tzid1; cur.dtstart = parsed1 }
            } else if (propName === "DTEND") {
                var tzid2   = propParam(ln, "TZID") || cur.tzid
                cur.dtend   = parseDt(propValue(ln), tzid2)
            } else if (propName === "EXDATE") {
                var tzid3   = propParam(ln, "TZID") || cur.tzid
                var exVals  = propValue(ln).split(",")
                for (var evi = 0; evi < exVals.length; evi++) {
                    var exParsed = parseDt(exVals[evi].trim(), tzid3)
                    if (exParsed) cur.exdates.push(exParsed)
                }
            } else if (propName === "RECURRENCE-ID") {
                var tzid4        = propParam(ln, "TZID") || cur.tzid
                cur.recurrenceId = parseDt(propValue(ln), tzid4)
            }
        }

        // Attach any orphan overrides to their masters
        for (var orphi = 0; orphi < orphanOverrides.length; orphi++) {
            var orph = orphanOverrides[orphi]
            if (orph.uid !== null && uidIndex[orph.uid] !== undefined)
                masters[uidIndex[orph.uid]].overrides.push(orph.ov)
        }

        // Expand all masters into concrete occurrences
        var allOccs = []
        var dateSet = []

        for (var mi = 0; mi < masters.length; mi++) {
            var master = masters[mi]
            if (!master.dtstart) continue
            if (master.status === "CANCELLED") continue

            var occs = expandRrule(
                master.rrule, master.dtstart, master.dtend,
                master.exdates, master.overrides, windowStart, windowEnd
            )

            for (var oci = 0; oci < occs.length; oci++) {
                var occ = occs[oci]
                allOccs.push({
                    title:  master.title,
                    allDay: master.dtstart.allDay,
                    start:  occ.start,
                    end:    occ.end,
                    rawH:   occ.rawH,
                    rawMin: occ.rawMin,
                    cal:    calName || ""
                })
                var dk = dateKey(occ.start)
                var found = false
                for (var dki = 0; dki < dateSet.length; dki++) {
                    if (dateSet[dki] === dk) { found = true; break }
                }
                if (!found) dateSet.push(dk)
            }
        }

        // Sort and return — mergeAndPublish() does the final combination
        allOccs.sort(function(a, b) { return a.start - b.start })
        return { upcoming: allOccs, dateSet: dateSet }
    }

    // Merge all calendars and publish combined events/eventDates
    function mergeAndPublish() {
        var allOccs = []
        var dateSet = []

        var sources    = [_canvasText,  _eventsText,  _meetingsText]
        var calNames   = ["canvasCal", "eventsCal", "meetingsCal"]
        for (var si = 0; si < sources.length; si++) {
            if (!sources[si] || sources[si].length === 0) continue
            var result = parseIcs(sources[si], calNames[si])
            // Merge occurrences
            for (var ri = 0; ri < result.upcoming.length; ri++) {
                allOccs.push(result.upcoming[ri])
            }
            // Merge date keys
            for (var di = 0; di < result.dateSet.length; di++) {
                var dk = result.dateSet[di]
                var found = false
                for (var dki = 0; dki < dateSet.length; dki++) {
                    if (dateSet[dki] === dk) { found = true; break }
                }
                if (!found) dateSet.push(dk)
            }
        }

        // Sort combined list and keep next 14
        allOccs.sort(function(a, b) { return a.start - b.start })
        var now      = new Date()
        var windowStart = new Date(); windowStart.setHours(0,0,0,0)
        var upcoming = []
        for (var ui = 0; ui < allOccs.length; ui++) {
            var ev = allOccs[ui]
            var notDone = ev.end ? ev.end >= now : ev.start >= windowStart
            if (notDone && upcoming.length < 14) upcoming.push(ev)
        }

        events     = upcoming
        eventDates = dateSet
    }

    function fmtTime(h, m) {
        var ampm = h >= 12 ? "pm" : "am"
        var h12  = h % 12 === 0 ? 12 : h % 12
        return h12 + (m > 0 ? ":" + (m < 10 ? "0" : "") + m : "") + ampm
    }

    function friendlyDate(evt) {
    var now = new Date()
    now.setHours(0, 0, 0, 0)
    var d = new Date(evt.start)
    d.setHours(0, 0, 0, 0)
    var diff    = Math.round((d - now) / 86400000)
    var timeStr = evt.allDay ? "" : (" " + fmtTime(evt.start.getHours(), evt.start.getMinutes()))
    if (diff === 0) return "Today"    + timeStr
    if (diff === 1) return "Tomorrow" + timeStr
    if (diff <  7)  return Qt.formatDate(evt.start, "dddd") + timeStr
    return Qt.formatDate(evt.start, "MMM d") + timeStr
}

}
