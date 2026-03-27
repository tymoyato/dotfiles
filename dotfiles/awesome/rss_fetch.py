import sys, json, urllib.request, xml.etree.ElementTree as ET

feeds   = json.loads(sys.argv[1])
max_per = int(sys.argv[2])
results = []

for url in feeds:
    try:
        req  = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        data = urllib.request.urlopen(req, timeout=10).read()
        root = ET.fromstring(data)
        ns   = {"atom": "http://www.w3.org/2005/Atom"}

        items = root.findall(".//item")
        if items:
            feed_name = root.findtext(".//channel/title") or url
            for item in items[:max_per]:
                title = item.findtext("title") or ""
                link  = item.findtext("link")  or ""
                date  = item.findtext("pubDate") or ""
                results.append({"title": title.strip(), "url": link.strip(),
                                 "feed": feed_name.strip(), "date": date.strip()[:16]})
        else:
            feed_name = root.findtext("atom:title", ns) or url
            for entry in root.findall("atom:entry", ns)[:max_per]:
                title = entry.findtext("atom:title", ns) or ""
                lel   = entry.find("atom:link", ns)
                link  = lel.get("href") if lel is not None else ""
                date  = entry.findtext("atom:updated", ns) or ""
                results.append({"title": title.strip(), "url": link.strip(),
                                 "feed": feed_name.strip(), "date": date.strip()[:16]})
    except Exception as e:
        sys.stderr.write(str(e) + "\n")

print(json.dumps(results, separators=(',', ':')))
