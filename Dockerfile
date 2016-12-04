FROM skranz/rskranz:latest

# based on skranz/shinyrstudio
# so we already have
# rstudio + shiny + hadleyverse R packages
# rskranz installs several additional packages

MAINTAINER Sebastian Kranz "sebastian.kranz@uni-ulm.de"

# install and start cron
RUN apt-get update && apt-get install -y cron
COPY start_cron.sh /etc/cont-init.d/start_cron.sh

# copy and run package installation file
COPY install.r /tmp/install.r
RUN Rscript /tmp/install.r
