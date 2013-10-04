INSTRUCCIONES DE INSTALACIÓN

El primer paso consiste en instalar algunos paquetes y módulos de perl desde CPAN. El segundo paso consiste en crear los modelos de base de datos para Catalyst (ver más adelante) e instalar el wrapper para Wkhtmltopdf. Consulte el manual en el directorio docs para más detalles como la publicación en un servidor web.

-----

Instalación manual en Debian Wheezy:

- Instalar paquetes requeridos:

	# apt-get install wkhtmltopdf xvfb libcatalyst-perl libcatalyst-modules-perl libgraphics-primitive-perl libdatetime-format-mysql-perl libclass-csv-perl libchart-clicker-perl libdbd-sqlite3-perl

- Instalar algunos módulos de cpan:

	# cpanp install Catalyst::View::Graphics::Primitive Paper::Specs Catalyst::View::Wkhtmltopdf

El binario Wkhtmltopdf requiere acceso a X. Cuando la publicación se realiza en un servidor web se requiere un wrapper para xvfb-run. Por favor, copie scripts/wkhtmltopdf-catalyst a /usr/local/bin y hágalo ejecutable (chmod 755 /usr/local/bin/wkhtmltopdf).

Si se requiere cambiar la ubicación o nombre del wrapper o utilizar el wkhtmltopdf original abra lib/Astatistics.pm y ajuste el comando a invocar en los ajustes de la configuración de View::Wkhtmltopdf.

-----

Instalación automática en Debian Squeeze:

En Debian Squeeze se han de realizar algunos pasos adicionales debido a que Astatistics requiere diferentes versiones de algunos de los paquetes y algunos módulos de cpan no se instalan limpiamente debido a un bug en el proceso de compilación de DBIx::Class y Moose. Para simplificar la instalación en este tipo de sistemas hemos creado un script de instalación automática:

- Ejecute script/install-squeeze.sh

Instalación manual en Debian Squeeze:

- Primero instale el sistema base.
- Luego:
  $ sudo apt-get install wkhtmltopdf libtest-nowarnings-perl libexpat-dev pkg-config libcairo-dev
- Instale cpan y cpanplus:
	$ sudo cpanp install CPAN
	$ sudo cpan CPANPLUS
	It will install also pre-requisites.
- Instale Params::Validate:
	$ sudo cpan Params::Validate
- Instale Moose:
	$ sudo cpan Moose
- Instale DBIx::Class con la opción force debido a un bug en el test de reconexión SQLite:
	$ sudo cpan -fi DBIx::Class
- haga configure:
	$ perl Makefile.PL build
- haga make:
	$ sudo make
	Este paso ha de invocarse como root por ser requisito para la instalación de dependencias.

Finalmente instale el wrapper wkhtmltopdf:

El binario Wkhtmltopdf requiere acceso a X. Cuando la publicación se realiza en un servidor web se requiere un wrapper para xvfb-run. Por favor, copie scripts/wkhtmltopdf-catalyst a /usr/local/bin y hágalo ejecutable (chmod 755 /usr/local/bin/wkhtmltopdf).

Si se requiere cambiar la ubicación o nombre del wrapper o utilizar el wkhtmltopdf original abra lib/Astatistics.pm y ajuste el comando a invocar en los ajustes de la configuración de View::Wkhtmltopdf.

