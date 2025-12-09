from .base import Extractor
import json

class JSONExtractor(Extractor):
    def extract(self, data: bytes) -> list[dict]:
        try:
            result = json.loads(data.decode('utf-8'))
            print("{}".format(result))
            if isinstance(result, dict):
                return [result]
            elif isinstance(result, list):
                return result
            else:
                print(f"[JSONExtractor] Unexpected JSON structure: {type(result)}")
                return []
        except Exception as e:
            print(f"[JSONExtractor] Error parsing JSON: {e}")
        return result
