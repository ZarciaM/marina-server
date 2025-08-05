FROM ocaml/opam:debian-12

USER root
RUN apt update && apt install -y m4 pkg-config libgmp-dev zlib1g-dev python3 python3-pip make sudo

USER opam
RUN opam switch create 4.14.0 && eval $(opam env) && opam install dune

WORKDIR /home/opam/app
COPY . .

USER root
RUN chown -R opam:opam /home/opam/app

USER opam
RUN eval $(opam env) && cd marina && make
RUN chmod +x /home/opam/app/marina/marina

USER root
RUN pip3 install --break-system-packages -r api/requirements.txt

EXPOSE 10000
ENV PORT=10000
CMD ["python3", "api/api.py"]
