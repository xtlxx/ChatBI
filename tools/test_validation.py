import sys
import os
sys.path.insert(0, os.path.abspath('.'))
import sqlglot
from agent.tools import validate_and_format_sql

sql1 = "SELECT * FROM (SELECT * FROM acc_product_shipment WHERE del_flag = '0' AND is_available = '0') a"

try:
    print(validate_and_format_sql(sql1, dialect='mysql'))
except Exception as e:
    print("Error 1:", e)

