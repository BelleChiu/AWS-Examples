import random
from datetime import datetime, timedelta

def generate_log_records(num_records=7):
    # Base time for the log generation
    base_time = datetime(2024, 10, 2, 12, 1, 15)
    
    # Possible data for generation
    ips = [f"192.168.1.{i}" for i in range(1, num_records + 1)]
    usernames = ["-", "john", "jane", "guest"]
    methods = ["GET", "POST"]
    uris = ["/index.html", "/login.php", "/about.html", "/products.html", "/cart.php", "/contact.html", "/checkout.php"]
    statuses = [200, 404, 500]
    sitename = "www.example.com"
    computername = "WEB01"
    server_ip = "10.0.0.1"

    records = []
    for i in range(num_records):
        # Generate record data
        timestamp = base_time + timedelta(seconds=i)
        c_ip = ips[i]
        username = random.choice(usernames)
        method = random.choice(methods)
        uri_stem = random.choice(uris)
        uri_query = "-" if method == "GET" else "user=admin" if uri_stem == "/login.php" else "add_item=12345"
        sc_status = random.choice(statuses)
        sc_substatus = 0
        sc_win32_status = random.choice([0, 2, 3])
        time_taken = random.randint(10, 50)

        # Format the log entry
        log_entry = f"{timestamp.strftime('%Y-%m-%d %H:%M:%S')} {c_ip} {username} {sitename} {computername} {server_ip} {method} {uri_stem} {uri_query} {sc_status} {sc_substatus} {sc_win32_status} {time_taken}"
        records.append(log_entry)
    
    return records

# Generate the records
log_records = generate_log_records()
for record in log_records:
    print(record)
