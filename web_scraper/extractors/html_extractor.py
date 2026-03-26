from lxml import html
from .base import Extractor


class HTMLExtractor(Extractor):
    def extract(self, data: bytes, root_tag: str = None) -> list[dict]:
        """
        data: Raw HTML bytes
        root_tag: XPath or CSS selector identifying repeating elements (e.g. "//div[@class='station']")
        """

        result: list[dict] = []
        try:
            tree = html.fromstring(data)

            if not root_tag:
                raise ValueError("root_tag must be provided for HTML extraction")

            elements = tree.xpath(root_tag)

            for el in elements:
                rec: dict = {}

                rec.update(el.attrib)

                leaf_elements = [d for d in el.iterdescendants() if len(d) == 0]

                if leaf_elements:
                    for leaf in leaf_elements:
                        key = _local_name(leaf.tag)
                        if key in rec:
                            continue
                        text = leaf.text_content().strip() if leaf.text_content() else None
                        rec[key] = text if text != "" else None
                else:
                    text = el.text_content().strip() if el.text_content() else None
                    if text:
                        rec["text"] = text

                result.append(rec)
        except Exception as e:
            print(f"[HTMLExtractor] Error parsing HTML: {e}")

        print(result)

        return result
        
    def _local_name(tag: str) -> str:
        if isinstance(tag, str) and "}" in tag:
            return tag.split("}", 1)[1]
        return tag