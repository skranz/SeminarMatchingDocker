FROM skranz/rskranz:latest

# based on skranz/shinyrstudio
# so we already have
# rstudio + shiny + hadleyverse R packages
# rskranz installs several additional packages

MAINTAINER Sebastian Kranz "sebastian.kranz@uni-ulm.de"

# install postfix or sendmail
RUN apt-get update
#RUN apt-get install -y postfix
RUN apt-get install -y sendmail

# copy and run package installation file
COPY install.r /tmp/install.r
RUN Rscript /tmp/install.r
