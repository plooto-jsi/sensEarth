import logging
from logging.handlers import RotatingFileHandler

# Create a logger
logger = logging.getLogger("sensearth_app")
logger.setLevel(logging.INFO) # DEBUG, INFO, WARNING, ERROR, CRITICAL

# Console handler
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)

# File handler (rotates logs when file gets too big)
# file_handler = RotatingFileHandler("sensearth.log", maxBytes=5_000_000, backupCount=3)
# file_handler.setLevel(logging.INFO)

# # Formatter
formatter = logging.Formatter(
    "[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s"
)
console_handler.setFormatter(formatter)
# file_handler.setFormatter(formatter)

# Handlers
logger.addHandler(console_handler)
# logger.addHandler(file_handler)
