# Random Forests medición alternativa de la importancia de los atributos

Trabajo Fin de Máster. \
Alumno [Francisco Saucedo](https://www.linkedin.com/in/franciscosaucedo/). \
[Máster Universitario en Ingeniería Informática](https://www.upo.es/postgrado/Master-Oficial-Ingenieria-Informatica/). \
[Universidad Pablo de Olavide](https://www.upo.es).

## Requisito: registro de librerías para cálculo de la MSU

```
mvn install:install-file -Dfile=lib/nbp-jcommonutils-master.jar \
    -DgroupId=upo \
    -DartifactId=jcu \
    -Dversion=1.0.0 \
    -Dpackaging=jar \
    -DgeneratePom=true
    
mvn install:install-file -Dfile=lib/nbp-jmachinelearning-master.jar \
    -DgroupId=upo \
    -DartifactId=jml \
    -Dversion=1.0.0 \
    -Dpackaging=jar \
    -DgeneratePom=true
```

## Uso

* Compilación

```
mvn clean install -DskipTests=true
```

* Utilidad para comparativas entre versiones estándar de RandomForest/RandomTree y las creadas en el TFM que usan MSU

** Obtener ayuda
```
cli/msu.sh
```

** Comparativa sobre un conjunto ejemplo de Weka

```
cli/msu.sh weather.nominal
```