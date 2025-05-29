from pathlib import Path
import datetime

LOG_PATH = Path(__file__).parent / "log.txt"


def logger(message, function_start, type="INFO"):
    with open(LOG_PATH, "a") as f:
        f.write(f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - {function_start} - {message}\n")
    if function_start != "" and function_start != "check_and_start" and type != "ERROR":
        print(f"{type}: {message}")