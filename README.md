THE SOFTWARE IS CURRENTLY IN TEST PHASE
  
Docker container to deploy the R shiny app SeminarMatching: a web-based framework to assign students to seminar slots using the Gale-Shapley algorithm.
There are several apps for admins, teachers and students. A detailed description is not yet available.

It is currently tested. The container is build upon shinyrstudio, i.e. you can use the rstudio server webinterface to log in inside the container. See the docker hub repository skranz/shinyrstudio for more details and information about the run command below.

```
docker run -entrypoint="/usr/bin/with-contenv bash" --name seminarmatching -d -p 8701:8787 -p 3801:3838 \
  -e ROOT=TRUE -e USER=<YourUsername> -e PASSWORD=<YourSecurePassword> \
  -e RUN_RSTUDIO=yes -e RUN_SHINY=yes \
  -v ~/docker/shiny/app/:/srv/shiny-server/ \
  -v ~/docker/shinyrstudio/container_home:/home/<YourUsername>/work \
  -v /srv/shinylog/:/var/log/ \
  skranz/seminarmatching:latest  
```

### Configure crontab to run autorun.R

TO DO