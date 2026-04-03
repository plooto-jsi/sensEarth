import csv
import io
from .base import Extractor

class CSVExtractor(Extractor):
    def extract(self, data: bytes, root_tag: str = ";") -> list[dict]:
        """
        data: Raw bytes from fetcher.
        root_tag: Used here as the delimiter (default is comma). 
        """
        result = []
        try:
            content = data.decode("utf-8")
            f = io.StringIO(content)
            
            reader = csv.DictReader(f, delimiter=";")
            
            for row in reader:
                clean_row = {k.strip(): v.strip() for k, v in row.items() if k is not None}
                result.append(clean_row)
                
        except Exception as e:
            print(f"[CSVExtractor] Error parsing CSV: {e}")
            
        return result