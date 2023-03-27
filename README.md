# Random Forests medición alternativa de la importancia de los atributos

Trabajo Fin de Máster. \
Alumno [Francisco Saucedo](https://www.linkedin.com/in/franciscosaucedo/). \
[Máster Universitario en Ingeniería Informática](https://www.upo.es/postgrado/Master-Oficial-Ingenieria-Informatica/). \
[Universidad Pablo de Olavide](https://www.upo.es).

## Bitácora actividades

* Copia y registro de librerías

```
LIB_MSU=~/Desarrollo/Soporte/LibreriasMSU;export LIB_MSU
WEKA_PROJECT_HOME=~/Desarrollo/MasterIIUPO/TFM/weka-stable-3-8/weka/lib;export WEKA_PROJECT_HOME

cp $LIB_MSU/nbp-jcommonutils-master.jar $WEKA_PROJECT_HOME
cp $LIB_MSU/nbp-jmachinelearning-master.jar $WEKA_PROJECT_HOME

mvn install:install-file -Dfile=$WEKA_PROJECT_HOME/nbp-jcommonutils-master.jar \
    -DgroupId=upo \
    -DartifactId=jcu \
    -Dversion=1.0.0 \
    -Dpackaging=jar \
    -DgeneratePom=true
    
mvn install:install-file -Dfile=$WEKA_PROJECT_HOME/nbp-jmachinelearning-master.jar \
    -DgroupId=upo \
    -DartifactId=jml \
    -Dversion=1.0.0 \
    -Dpackaging=jar \
    -DgeneratePom=true
```
