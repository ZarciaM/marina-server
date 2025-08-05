FROM ocaml/opam:debian-12

# Installe Python et pip
USER root
RUN apt update && apt install -y python3 python3-pip

# Dossier de travail
WORKDIR /app

# Copie tout le projet
COPY . .

# Compile marina (depuis ./marina)
RUN cd marina && make

# Installe Flask
RUN pip3 install -r api/requirements.txt

# Expose port pour Flask
EXPOSE 10000

# Lance l'API Flask
CMD ["python3", "api/app.py"]
