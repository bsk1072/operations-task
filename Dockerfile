# pull official base image
FROM python:3.10.2-slim-buster

# set work directory
WORKDIR /usr/src/app

# install psycopg2 dependencies
RUN apt-get update \
  && apt-get -y install gcc postgresql \
  && apt-get -y install python3-pip \
  && apt-get clean

# install dependencies
RUN pip install --upgrade pip
RUN pip install -U gunicorn
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# copy project
COPY rates .

CMD ["gunicorn", "-b", ":3000", "wsgi"]
