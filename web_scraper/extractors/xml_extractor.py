from lxml import etree
from .base import Extractor

class XMLExtractor(Extractor):
    def extract(self, data: bytes, root_tag: str = None) -> list[dict]:
        """
        data: The raw bytes from the fetcher
        root_tag: The key in the JSON object where the list of records is located.
        """
        result = []
        try:
            root = etree.fromstring(data)
            stations = root.findall(f".//{root_tag}")
            for st in stations:
                rec = dict(st.attrib)
                for child in st:
                    rec[child.tag] = child.text
                result.append(rec)
        except Exception as e:
            print(f"[XMLExtractor] Error parsing XML: {e}")
        return result
