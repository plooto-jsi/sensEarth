import requests
from storage_pipeline import store_raw_response 

class Fetcher:
    """Basic fetcher using requests."""
    def fetch(self, url: str) -> bytes:
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            store_raw_response(response) # Uncomment for storing raw responses
            return response.content
        except requests.RequestException as e:
            print(f"[Fetcher] Error fetching {url}: {e}")
            return b""
