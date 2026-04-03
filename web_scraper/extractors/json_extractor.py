from .base import Extractor
import json

class JSONExtractor(Extractor):
    def extract(self, data: bytes, root_tag: str = "data") -> list[dict]:
        """
        data: The raw bytes from the fetcher
        root_tag: The key in the JSON object where the list of records is located.
        If the JSON is a list at the top level, root_tag can be ignored.
        """
        result = []
        try:
            parsed_data = json.loads(data)
            
            if isinstance(parsed_data, list):
                result = parsed_data
            
            elif isinstance(parsed_data, dict):
                result = parsed_data.get(root_tag, [])

                if not isinstance(result, list):
                    result = [result] 
            
        except Exception as e:
            print(f"[JSONExtractor] Error parsing JSON: {e}")
            
        return result
