#!/usr/bin/env python

import sys, os
import requests
from datetime import datetime, timedelta
import typer


def check_file_status(filepath, filesize):
    sys.stdout.write("\r")
    sys.stdout.flush()
    size = int(os.stat(filepath).st_size)
    percent_complete = (size / filesize) * 100
    sys.stdout.write("%.3f %s" % (percent_complete, "% Completed"))
    sys.stdout.flush()


def daterange(start_date, end_date):
    for n in range(int((end_date - start_date).days) + 1):
        yield start_date + timedelta(n)


def main(
    startdate: datetime = typer.Option(...),
    enddate: datetime = typer.Option(...),
    username: str = typer.Option(...),
    passwd: str = typer.Option(...),
    cycle: str = typer.Option("00"),
):
    ret = authenticate(username, passwd)
    if ret.status_code != 200:
        print("Bad Authentication")
        print(ret.text)
        raise ValueError("Bad Authentication")

    filePathTemplate = (
        "/data/ds084.1/{year}/{day}/gfs.0p25.{day}{cycle}.f{fhr:03d}.grib2"
    )

    dspath = "https://rda.ucar.edu"

    # Try to get password
    for date in daterange(startdate, enddate):
        day = date.strftime("%Y%m%d")
        year = day[:4]
        fDir = f"{day}"
        os.makedirs(fDir, exist_ok=True)
        for fhr in range(0, 243, 3):
            fileNm = filePathTemplate.format(year=year, day=day, cycle=cycle, fhr=fhr)
            filename = dspath + fileNm
            out_file = os.path.join(fDir, os.path.basename(fileNm))
            print(f"Downloading {out_file}")
            req = requests.get(
                filename, cookies=ret.cookies, allow_redirects=True, stream=True
            )
            filesize = int(req.headers["Content-length"])
            with open(out_file, "wb") as outfile:
                chunk_size = 1048576
                for chunk in req.iter_content(chunk_size=chunk_size):
                    outfile.write(chunk)
                    if chunk_size < filesize:
                        check_file_status(out_file, filesize)
            check_file_status(out_file, filesize)
            print()


def authenticate(username, pswd):
    url = "https://rda.ucar.edu/cgi-bin/login"
    values = {"email": username, "passwd": pswd, "action": "login"}

    # Authenticate
    ret = requests.post(url, data=values)
    return ret


def get_pswd():
    if len(sys.argv) < 2 and not "RDAPSWD" in os.environ:
        try:
            import getpass

            input = getpass.getpass
        except:
            try:
                input = raw_input
            except:
                pass
        pswd = input("Password: ")
    else:
        try:
            pswd = sys.argv[1]
        except:
            pswd = os.environ["RDAPSWD"]
    return pswd


if __name__ == "__main__":
    typer.run(main)
