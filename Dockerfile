FROM julia:latest

RUN apt-get update && apt-get install -y \
	default-mysql-client \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN julia -e 'using Pkg; Pkg.add("MySQL"); Pkg.add("DBInterface")'

ENTRYPOINT ["/bin/bash"]

