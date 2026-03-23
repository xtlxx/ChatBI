
import logging
import os
from logging.handlers import RotatingFileHandler


def setup_file_logging():
    # Use parent directory logs to avoid reload loop
    log_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "logs")
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    log_file = os.path.join(log_dir, "backend_debug.log")

    handler = RotatingFileHandler(
        log_file, maxBytes=10*1024*1024, backupCount=5, encoding='utf-8'
    )
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    handler.setFormatter(formatter)

    root_logger = logging.getLogger()
    root_logger.addHandler(handler)
    root_logger.setLevel(logging.DEBUG) # Force DEBUG level for now

    print(f"File logging configured: {log_file}")

if __name__ == "__main__":
    setup_file_logging()
