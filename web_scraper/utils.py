import time
from requests.exceptions import RequestException

def retry_request(func, retries=5, delay=5, backoff=2, *args, **kwargs):
    """
    Retry a request function multiple times with exponential backoff.
    func: callable (like requests.post)
    retries: number of attempts
    delay: initial delay in seconds
    backoff: multiply delay each retry
    *args, **kwargs: passed to func
    """
    current_delay = delay
    for attempt in range(1, retries + 1):
        try:
            return func(*args, **kwargs)
        except RequestException as e:
            print(f"Attempt {attempt} failed: {e}. Retrying in {current_delay}s...")
            time.sleep(current_delay)
            current_delay *= backoff
    raise ConnectionError(f"Failed after {retries} attempts")