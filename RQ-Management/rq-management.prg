*/
*!*
*!*		Nombre: Cargue de Requisiciones desde Archivo Excel - Libreria Lerner
*!*
*!*		Autor: Nicol�s David Cubillos
*!*
*!*		Contenido: Cargue de Requisiciones desde Archivo Excel - Libreria Lerner
*!*
*!*		Fecha: 1 de junio de 2024
*!*
*/

*---------------------------------------------------

FUNCTION saveCantidadFinal(lcTipoDcto, lcNroDcto, lcCantidadFinal) AS STRING
lcSqlQuery = "UPDATE MVTRADE SET RQ_CANTIDAD_FINAL = " + TRANSFORM(lcCantidadFinal) + ;
			 " WHERE TIPODCTO = '" + TRANSFORM(lcTipoDcto) + "' AND NRODCTO = '" + TRANSFORM(lcNroDcto) + "'"
_CLIPTEXT = lcSqlQuery

IF SQLEXEC(ON, lcSqlQuery) != 1
	ERROR("Error al actualizar la cantidad final para el documento " + ALLTRIM(TRANSFORM(lcTipoDcto)) + ALLTRIM(TRANSFORM(lcNroDcto)) + ".")
ENDIF

ENDFUNC
