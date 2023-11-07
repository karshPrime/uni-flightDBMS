# Studying Users and Permissions with Flight Database

This project focuses on studying users and permissions within a database management system. It is implemented using the Julia programming language and utilizes MySQL as the chosen database system. This README provides guidance for setting up the project environment on a local machine.

## Prerequisites
Ensure that the following software is installed on the host machine:

- Julia (latest version)
- MySQL (latest version)

If these software are not yet installed, please follow the instructions provided below:


## Method 1: On Local System (manual install)
<details>
<summary> Setting the project on the local system. </summary>
<br>

**Note:** Please edit `line 9` in `authenticator.jl` and replace the IP address there with `'localhost'`

### Julia Installation

Access the [official Julia downloads page](https://julialang.org/downloads/) and download the binary that matches your operating system. Follow the provided instructions to install it.

### MySQL Installation

Download MySQL from the [official MySQL website](https://dev.mysql.com/downloads/installer/). Choose the version that corresponds to your operating system and install it following the provided instructions.

### Setup Julia Dependencies

This project utilizes the `MySQL` and `DBInterface` Julia libraries to interact with the database. You can add these libraries by first initializing the Julia built-in package manager:

```julia
julia> ]
```

Then, add the required packages:

```julia
(v1.x) pkg> add MySQL
(v1.x) pkg> add DBInterface
```

### Clone Repository
After installing all the required software, you can clone the repository:

```shell
git clone https://github.com/karshPrime/uni-flightDBMS.git
```

</details>

## Method 2: Using Docker Containers (reccomended)
<details>
<summary> Setting the project on docker containers using the Dockerfile provided. 
</summary>
<br>

Initilising MySQL docker container
```shell
$ docker pull mysql
$ docker docker run -e MYSQL_ROOT_PASSWORD=102874485 -d --name projectServer mysql
$ docker inspect projectServer | grep -i ipaddress
```
**Note**: if ipaddress isn't same as `172.17.0.2` please edit `line 9` in `authenticator.jl` with the correct ip.


Building Julia container with all dependencies configured
```shell
$ docker build -t client-img .
$ docker run -it --name clientAppFInal -v "C:\\Users\\user33\\Programs\\flight-dbms:/app" client-img
```

With this, you would be in the container shell. To continue connect to the other container MySQL using:
```shell
$ mysql -h 172.17.0.2 -u root -p
```
Change the `ipaddress` here if it isn't same as this one.

</details>

## Setting up the Project Database
The project involves two databases, each with two corresponding files. Use the following SQL commands to generate and populate the databases with random sample data:
```sql
SOURCE ./generate_admins.sql
SOURCE ./generate_flights.sql

SOURCE ./populate_admins.sql
SOURCE ./populate_flights.sql
```

## Running the Application
The project includes two applications: one for public usage (with public permissions) and the other for administrative functions. Start these applications as follows:

### Client Application:

```shell
$ julia interface_public.jl
```

### Admin Application:

```shell
$ julia interface_admin.jl
```
At this point, the project should be up and running on your local machine.
