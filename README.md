
# Random Forests medición alternativa de la importancia de los atributos

Trabajo Fin de Máster. \
Alumno [Francisco Saucedo](https://www.linkedin.com/in/franciscosaucedo/). \
[Máster Universitario en Ingeniería Informática](https://www.upo.es/postgrado/Master-Oficial-Ingenieria-Informatica/). \
[Universidad Pablo de Olavide](https://www.upo.es). \
**Fork del repositorio Weka oficial, versión 3.8, para Trabajo Fin de Máster**

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

### Compilación

```
mvn clean install -DskipTests=true
```

## Referencias

* [A multivariate approach to the symmetrical uncertainty measure: Application to feature selection problem](https://www.sciencedirect.com/science/article/abs/pii/S0020025519303603).
* [Weka 3: Machine Learning Software in Java](https://www.cs.waikato.ac.nz/ml/weka/index.html).