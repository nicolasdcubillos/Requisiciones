********************************************************
* Imprime formatos del sistema
* Fecha  Modificacion 31-May-2012
* Fecha  Compilacion 31-May-2012
********************************************************
***PROGRAMA: ImprimirFormato.Prg
***FUNCION:  Selecciona la informacion para imprimir los nuevos formatos del sistema ATLAS
********************************************************************
***VERSION:  ESTE PROGRAMA SOLO APLICA PARA LA VERSION 2012
******************************************************************
Parameters pNombreFormato,pOrigen,pTipoDcto,pDocumentoInicial,pDocumentoFinal,pTipoSalida,pCodigoConsecutivo,pCopias
mNroResol = " "
Formato=pNombreFormato
Store 1 To copiaActual
Public pNit,mNitResponsableRQ,mCodigoMonedaLocal,mCalculoValUn, mCalculoValUnNif
Store "" To pNit,mCodigoMonedaLocal
*copiaActual=pCopias


mCodigoMonedaLocal=oGenerica.Extraer_Variables(gConexEmp,gEmpresa,'CODMONEDALOCAL',gCodUsuario)
mCalculoValUnNif=oGenerica.Extraer_Variables(gConexEmp,gEmpresa,'CALCULOVALUNID',gCodUsuario)


Do Opcion With "CrearTablaTmpLogo"



mStrSQLx = " Select NroResol  " + ;
	"		From Consecut "  + ;
	"		Where Origen =?pOrigen And  "  + ;
	"			  TipoDcto=?pTipoDcto And  "  + ;
	"			  Codigocons=?pCodigoConsecutivo  "
If SQLExec(gConexEmp,mStrSQLx,"curResol")<=0
	oGenerica.Mensajes("No es posible seleccionar los datos de la Resoluci�n")
	Return 0
Endif
Select curResol
Go Top

If !Eof()
	mNroResol = Alltrim(curResol.NroResol)
Else
	mNroResol = " "
Endif



mTipoDct = pTipoDcto
********************************************************************
***VERSION:  ESTE PROGRAMA SOLO APLICA PARA LA VERSION 2012
******************************************************************
Do While pDocumentoInicial <= pDocumentoFinal

	documentoMostrar = Alltrim(Str(pDocumentoInicial))

***--------------------------------------------------------------------------------
***/// P7132 - William Villada - Febrero DE 2012 - Se crea la siguiente consulta para verificar el tipo de documento correcto con
***///        el cual se graban los documentos. Esta consulta se hace especialmente para los casos de las facturas remisionadas
***///        las cuales cambian de tipo de documento. Esta consulta trae el tipo de documento con el cual se deben realizar las
***///        demas consultas.

	If Used("cFacRem")
		Select cFacRem
		Use
	Endif


***--------------------------------------------------------------------------------
***/// P7367 - Johana Sepulveda - Abril 2012 - Se crea la siguiente consulta para verificar el tipo de documento correcto con
***///        el cual se graban los documentos. Esta consulta se hace especialmente para los casos de las facturas remisionadas
***///        las cuales cambian de tipo de documento. Esta consulta trae el tipo de documento con el cual se deben realizar las
***///        demas consultas.

***/// Esta variable toma el codigo del consecutivo que viene desde la pantalla FrmImprimirFormatoComercial
***/// el cursor cConsecut se crea en ese formulario.
*pCodigoConsecutivo=cConsecut.CodigoCons

	mStrSql="  Select distinct Trade.TipoDcto "+;
		"	From Trade Inner join Consecut "+;
		"		on Consecut.Origen = Trade.Origen and Consecut.TipodctoFR = Trade.TipoDcto "+;
		"			And Consecut.codigocons=?pCodigoConsecutivo and Consecut.Tipodcto=?mTipoDct "+;
		"			and Trade.NroDcto= ?documentoMostrar  and Trade.origen = 'COM' "

	If SQLExec(gConexEmp,mStrSql,"cFacRem")<=0
		oGenerica.Mensajes("No es posible seleccionar la tabla de consecutivos")
		Return 0
	Endif

	Select cFacRem
	Go Top
	If !Eof()
		pTipoDcto = cFacRem.TipoDcto
	Else
		pTipoDcto = mTipoDct
	Endif

	If gPais ="MX"
		mStrSQl_MEUUID=" SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='TRADE' AND	COLUMN_NAME ='MEUUID' "
		If SQLExec(gConexEmp,mStrSQl_MEUUID,"cMEUUID") <=0
			oGenerica.Mensajes("No se realizo la consulta de SQL para extraer el campo MEUUID de TRADE")
			Return 0
		Endif

		Select cMEUUID
		Go Top
		If !Eof()
			mStrSql=" Select MEUUID,MECADORIG,MECANCELA,MEFALLO,MEFECHAT,MENOCERSAT,MESELLOCFD,MESELLOSAT,MEVERSION From Trade "+;
				" Where Origen=?pOrigen and Tipodcto=?pTipoDcto and Nrodcto=?documentoMostrar "
			If SQLExec(gConexEmp,mStrSql,"cListaCertificados") <=0
				oGenerica.Mensajes("No se realizo la consulta de SQL para extraer el campo MEUUID de TRADE")
				Return 0
			Endif
		Else
			mStrSql=" Select ' ' as MEUUID,' ' as MECADORIG,' ' as MECANCELA,' ' as MEFALLO,' ' as MEFECHAT,' ' as MENOCERSAT,' ' as MESELLOCFD,' ' as MESELLOSAT,' ' as MEVERSION From Trade "+;
				" Where Origen=?pOrigen and Tipodcto=?pTipoDcto and Nrodcto=?documentoMostrar "
			If SQLExec(gConexEmp,mStrSql,"cListaCertificados") <=0
				oGenerica.Mensajes("No se realizo la consulta de SQL para extraer el campo MEUUID de TRADE")
				Return 0
			Endif

		Endif
		Select cListaCertificados
		mMeuuid=Alltrim(cListaCertificados.Meuuid)

	Endif
***--------------------------------------------------------------------------------



	mStrSql = " Select V.*,M.Nombre As NombrePais ,T.Nombre As NombreMoneda ,P.Emailp As Emailp, 							"+;
		" [dbo].[F_MonedaForm](?pOrigen,?pTipoDcto,?documentoMostrar) as Moneda,								"+;
		"[dbo].[F_Extraer_Variable]('CALLE',?gCodusuario,?gPais) As Titulo1, "+;
		" [dbo].[F_Extraer_Variable]('NROEXTERIOR',?gCodusuario,?gPais) As Titulo2, "+;
		" [dbo].[F_Extraer_Variable]('NROINTERIOR',?gCodusuario,?gPais) As Titulo3, "+;
		" [dbo].[F_Extraer_Variable]('COLONIA',?gCodusuario,?gPais) As Titulo4, "+;
		" [dbo].[F_Extraer_Variable]('CP',?gCodusuario,?gPais) As Titulo5, "+;
		" [dbo].[F_Extraer_Variable]('LOCALIDAD',?gCodusuario,?gPais) As Titulo6, "+;
		" [dbo].[F_Extraer_Variable]('CIUDAD',?gCodusuario,?gPais) As Titulo7, "+;
		" [dbo].[F_Extraer_Variable]('ESTADOMX',?gCodusuario,?gPais) As Titulo8, "+;
		" [dbo].[F_Extraer_Variable]('CABELN4',?gCodusuario,?gPais) As Titulo9, "+;
		" [dbo].[F_Extraer_Variable]('NUMAUTDONAT',?gCodusuario,?gPais) As NoAutDonat, "+;
		" [dbo].[F_Extraer_Variable]('FECAUTDONAT',?gCodusuario,?gPais) As FechaAutDonat, "+;
		" [dbo].[F_MonedaConceptosForm](?pOrigen,?pTipoDcto,?documentoMostrar,'BRUTO') as VALBRUTO,				"+;
		" [dbo].[F_MonedaConceptosForm](?pOrigen,?pTipoDcto,?documentoMostrar,'DESCUENTO') as VALDESCUENTO,		"+;
		" [dbo].[F_MonedaConceptosForm](?pOrigen,?pTipoDcto,?documentoMostrar,'IVA') as VALIVA ,				"+;
		" [dbo].[F_MonedaConceptosForm](?pOrigen,?pTipoDcto,?documentoMostrar,'RETEFUENTE') as VALRETEFUENTE ,	"+;
		" [dbo].[F_MonedaConceptosForm](?pOrigen,?pTipoDcto,?documentoMostrar,'IPOCONSUMO') as VALIPOCONSUMO ,	"+;
		" [dbo].[F_MonedaConceptosForm](?pOrigen,?pTipoDcto,?documentoMostrar,'RETEIVA') as VALRETEIVA ,		"+;
		" [dbo].[F_MonedaConceptosForm](?pOrigen,?pTipoDcto,?documentoMostrar,'RETEICA') as VALRETEICA ,		"+;
		" [dbo].[F_MonedaConceptosForm](?pOrigen,?pTipoDcto,?documentoMostrar,'RETCREE') as VALRETCREE ,		"+;
		" [dbo].[F_MonedaConceptosForm](?pOrigen,?pTipoDcto,?documentoMostrar,'NETO') as VALNETO,				"+;
		" (Cast(Year(v.Fecha) as Char(4)) + '-' + 																"+;
		" Case When Len(Month(v.Fecha)) = 1 Then '0' + Cast(Month(v.Fecha) as Char(1)) 							"+;
		" Else Cast(Month(v.Fecha) as Char(2)) End + '-' + 														"+;
		" Case When Len(Day(v.Fecha)) = 1 Then '0' + Cast(Day(v.Fecha) as Char(1))								"+;
		" Else Cast(Day(v.Fecha) as CHAR(2)) End + 'T' + v.Hora) as fechacerti, 								"+;
		" (Cast(Year(v.Fecha) as Char(4)) + '-' + 																"+;
		" Case When Len(Month(v.Fecha)) = 1 Then '0' + Cast(Month(v.Fecha) as Char(1)) 							"+;
		" Else Cast(Month(v.Fecha) as Char(2)) End + '-' + 														"+;
		" Case When Len(Day(v.Fecha)) = 1 Then '0' + Cast(Day(v.Fecha) as Char(1))								"+;
		" Else Cast(Day(v.Fecha) as CHAR(2)) End + 'T' + v.Hora) as fechaefechat, 								"+;
		"  (V.Impuestos/(case when V.tcambio = 0 then 1 else V.tcambio end)) as Impuesto						"+;
		"	From vComerCom V,Mtpaises M ,Mtmoneda T ,MtProcli P                 								"+;
		"	Where 																								"+;
		"	V.Nit   =  P.Nit And 																				"+;
		"	V.codmoneda = T.Codmoneda And 																		"+;
		"	P.Pais = M.Codigo  And																				"+;
		"   V.Origen = ?pOrigen And  																			"+;
		"	V.NroDcto=?documentoMostrar and 																	"+;
		"	V.TipoDcto=?pTipoDcto	"

********************************************************************
***VERSION:  ESTE PROGRAMA SOLO APLICA PARA LA VERSION 2012
******************************************************************
	If SQLExec(gConexEmp,mStrSql,"curEncabezado")<=0
		oGenerica.Mensajes("No es posible seleccionar los datos del encabezado")
		Return 0
	Endif
	Select curEncabezado
	Go Top


	mNitResponsableRQ=curEncabezado.Nitresp

	If !Empty(curEncabezado.Nit)
		pNit=curEncabezado.Nit
	Else
		pNit=curEncabezado.Nitresp
	Endif



	If gPais ="MX"
**********************************************************
* Imprimir la informacion de la factura timbrada
**********************************************************
		mStrSql = 	" select MECADORIG,MEFECHAT, "+;
			"		substring(MESELLOCFD,0,125) + ' ' + substring(MESELLOCFD,125,125)  as MESELLOCFD, "+;
			"		substring(MESELLOSAT,0,150) + ' ' + substring(MESELLOSAT,150,100)  as MESELLOSAT,MEUUID, MEXML "+;
			" From trade "  + ;
			" Where Origen =?pOrigen And  "  + ;
			" TipoDcto=?pTipoDcto And  "  + ;
			" NroDcto=?documentoMostrar  "

		If SQLExec(gConexEmp,mStrSql,"CurMedElect")<=0
			oGenerica.Mensajes("No es posible seleccionar los datos del timbrado de facturaci�n electr�nica")
			Return 0
		Endif
		Select CurMedElect
	Endif


***---------------------------------------------------------------------
***///-- Enero 2012 - La funcion F_MonedaMVForm selecciona la informacion por el tipo de moneda con la cual se grab� el documento.

	mStrSql = " Select  M.* ,U.UNidad As CodUnidad,U.Nombre As NombreUnidad,[dbo].[F_MonedaMVForm](?pOrigen,?pTipoDcto,?documentoMostrar,M.idmvtrade) as ValorUnitario  " + ;
		"		From MVTrade M,MtUnidad U "  + ;
		"		Where Origen =?pOrigen And  "  + ;
		"			  NroDcto=?documentoMostrar And M.UndVenta = U.Unidad  and M.TipoDcto=?pTipoDcto "

	If SQLExec(gConexEmp,mStrSql,"curMvto")<=0
		oGenerica.Mensajes("No es posible seleccionar los datos del movimiento")
		Return 0
	Endif


	Select curMvto
	Go Top

	Sum All IpconsuBeb * Cantidad To mIpconsubeb

	Select curEncabezado



	Set Step On
	Do Case

	Case curEncabezado.Otramon = "N" And curEncabezado.Multimon = .F.   && Pesos
		mPalabra = numero(Abs(curEncabezado.valBruto - curEncabezado.valDescuento + curEncabezado.valIva + curEncabezado.VALIPOCONSUMO + mIpconsubeb - curEncabezado.Valretefuente + curEncabezado.Valreteiva + curEncabezado.Valreteica),Upper(curEncabezado.Moneda))
*mPalabra = numero(Abs((CurEncabezado.valbruto+CurEncabezado.valiva-Curencabezado.valdescuento)-(CurEncabezado.valretefuente+CurEncabezado.valretcree+CurEncabezado.valreteiva+CurEncabezado.valreteica)))
	Case curEncabezado.Otramon = "S" And curEncabezado.Multimon  = .F. && Dolar - Otramoneda
		mPalabra = numero(Abs(curEncabezado.valBruto - curEncabezado.valDescuento + curEncabezado.valIva + curEncabezado.VALIPOCONSUMO + mIpconsubeb - curEncabezado.Valretefuente + curEncabezado.Valreteiva + curEncabezado.Valreteica),Upper(curEncabezado.Moneda))

	Case curEncabezado.Otramon = "N" And curEncabezado.Multimon = .T.  && Multimoneda
		mPalabra = numero(Abs(curEncabezado.valBruto - curEncabezado.valDescuento + curEncabezado.valIva + curEncabezado.VALIPOCONSUMO + mIpconsubeb - curEncabezado.Valretefuente + curEncabezado.Valreteiva + curEncabezado.Valreteica),Upper(curEncabezado.Moneda))

	Otherwise
		mPalabra = numero(Abs(curEncabezado.valBruto - curEncabezado.valDescuento + curEncabezado.valIva + curEncabezado.VALIPOCONSUMO + mIpconsubeb - curEncabezado.Valretefuente + curEncabezado.Valreteiva + curEncabezado.Valreteica),Upper(curEncabezado.Moneda))

	Endcase


	Select curMvto
	Go Top

***---------------------------------------------------------------------
********************************************************************

******************************************************************
	If curEncabezado.D1Fecha1 > 0

		Do Case
		Case curEncabezado.Otramon = "N" And curEncabezado.Multimon = .F.   && Pesos
			mValorDesc1 = (curEncabezado.Bruto - curEncabezado.Descuento)-((curEncabezado.Bruto - curEncabezado.Descuento) * (curEncabezado.D1Fecha1/100))
		Case curEncabezado.Otramon = "S" And curEncabezado.Multimon = .F. && Dolar - Otramoneda
			mValorDesc1 = (curEncabezado.XBruto - curEncabezado.XDescuento)-((curEncabezado.XBruto - curEncabezado.XDescuento) * (curEncabezado.D1Fecha1/100))
		Case curEncabezado.Otramon = "N" And curEncabezado.Multimon = .T.&& Multimoneda
			mValorDesc1 = (curEncabezado.ZBruto - curEncabezado.ZDescuento)-((curEncabezado.ZBruto - curEncabezado.ZDescuento) * (curEncabezado.D1Fecha1/100))
		Endcase

		mTextDesc1 = "Descuento por pronto pago "
		mTextDesc2 = "% cuyo valor es $:"
		mTextDesc3 = "Pague solo $ "
		mTextDesc4 = "Antes del "


	Else && Si no tiene descuento financiero
		mValorDesc1 = 0
		mTextDesc1 = ""
		mTextDesc2 = ""
		mTextDesc3 = ""
		mTextDesc4 = ""
	Endif


	mCodciudad=curEncabezado.CdCiiu
	mStrSql = " Select Nomciud From  MTCDDAN Where Codigo = ?mCodciudad "
	If SQLExec(gConexEmp,mStrSql,"curSucursales2")<=0
		Do errconex With " No se realizo la consulta para determinar las sucursales"
	Endif
	mNombreCiudad =curSucursales2.Nomciud


****/// Validacion del codigo IVA. Si el movimiento tiene varios se deja vacio
	Select curMvto
	Go Top
	mlineas=Reccount()
	mIvaMvto=curMvto.IVA


	For A=1 To mlineas
		If curMvto.IVA <> mIvaMvto
			mIvaMvto= 0
			Exit
		Endif
		Skip
	Endfor


***///
*--******************************************************************--
*--JAVIER OSPINA
*--IMPUESTOS ADICIONALES 7070-7072
*--AIU P6927
*--12/ABRIL/2012
*--Descripcion:
*--Pivot dinamicos para imprimir los valores de impuestos
*--Para los formatos de impresion se deja esta consulta
*--en el programa imprimirformato de facturas para que arme
*--el query dinamicamente dependiendo de los impuestos que se tengan
*--configurados en el maestro de impuestos.
*--******************************************************************--

*--los parametros tipo de documento, # de dcto y origen son la base
*--para la consulta dinamica ya que con estos datos se consulta en mvtrade
*--los id de los impuestos asociados a la factura y poder construir el pivot
*--dinamico de los impuestos con su porcentaje y el valor que le corresponde
*--para esa factura.

	If gImpuestosComp=.T.
		mStrSql1 = " Declare @TipoDcto Char (20)  			"+;
			"	Declare @NroDcto Char (20)   					"+;
			"	Declare @Origen Char (20)   					"+;
			"	Declare @Sql varchar(MAX) 						"+;
			"	Declare @sql2 varchar(max)  					"+;
			"	Declare @Consulta_Iva2 Char (1000)    			"+;
			"	Declare @Consulta_Base2 Char (1000)   			"+;
			"	Declare @Porc_Iva2 Char (1000)   				"+;
			"	Declare @Base2 Char (1000)   					"+;
			"	Declare @Consulta_Iva Char (1000)  				"+;
			"	Declare @Consulta_Base Char (1000)  			"+;
			"	Declare @Porc_Iva Char (1000)   				"+;
			"	Declare @Base Char (1000)   					"+;
			"	Declare @Total_Iva Char (1000)   				"+;
			"	Declare @Total_Base Char (1000)   				"+;
			"	select @Total_Base=coalesce(Rtrim(@Total_Base)+', sum([Porcen_'+Rtrim(impuestos.CODIGO)+'])As [Porcen_','sum([Porcen_'+Rtrim(impuestos.CODIGO)+'])As [Porcen_')+ Rtrim(impuestos.CODIGO)+']'  	"+;
			"	From (	 	 															"+;
			"		  select Distinct convert(Char(5),CODIGO)As CODIGO  from Mtimpu   	"+;
			"		 ) impuestos   														"+;
			"			Order by CODIGO   												"+;
			"	select @Total_Iva=coalesce(Rtrim(@Total_Iva)+', sum([Valor_'+Rtrim(impuestos.CODIGO)+'])As [Valor_','sum([Valor_'+Rtrim(impuestos.CODIGO)+'])As [Valor_')+ Rtrim(impuestos.CODIGO)+']'   		"+;
			"	From ( 	 				 												"+;
			"		   select Distinct convert(Char(5),CODIGO)As CODIGO  from Mtimpu   	"+;
			"		 ) impuestos   														"+;
			"			Order by CODIGO   												"+;
			"	select @Consulta_Base=coalesce(Rtrim(@Consulta_Base)+', isnull(['+Rtrim(impuestos.CODIGO)+'],0)As [Porcen_','isnull(['+Rtrim(impuestos.CODIGO)+'],0)As [Porcen_')+ Rtrim(impuestos.CODIGO)+']'  "+;
			"	From (   																"+;
			"		 select Distinct convert(Char(5),CODIGO)As CODIGO  from Mtimpu   	"+;
			"		) impuestos   														"+;
			"		Order by CODIGO   													"+;
			"	select @Consulta_Iva=coalesce(Rtrim(@Consulta_Iva)+', isnull([-'+Rtrim(impuestos.CODIGO)+'],0)As [Valor_','isnull([-'+Rtrim(impuestos.CODIGO)+'],0)As [Valor_')+ Rtrim(impuestos.CODIGO) +']'  	"+;
			"	From (   																"+;
			"		 select Distinct convert(Char(5),CODIGO)As CODIGO  from Mtimpu 		"+;
			"		) impuestos   														"+;
			"		Order by CODIGO  													"+;
			"	select @Base=coalesce(Rtrim(@Base)+', ['+Rtrim(impuestos.CODIGO)+']','['+Rtrim(impuestos.CODIGO)+']')   			"+;
			"	From (   																											"+;
			"		 select Distinct convert(Char(5),CODIGO)As CODIGO  from Mtimpu   												"+;
			"		) impuestos   																									"+;
			"		Order by CODIGO   																								"+;
			"	select @Porc_Iva=coalesce(Rtrim(@Porc_Iva)+', [-'+Rtrim(impuestos.CODIGO)+']','[-'+Rtrim(impuestos.CODIGO)+']')   	"+;
			"	From (   																											"+;
			"		 select Distinct convert(Char(5),CODIGO)As CODIGO  from Mtimpu  												"+;
			"		) impuestos   																									"+;
			"		Order by CODIGO   																								"+;
			"	select @Consulta_Base2=coalesce(Rtrim(@Consulta_Base2)+', isnull([-'+Rtrim(impuestos.CODIGO)+'],0)As [Porcen_','isnull([-'+Rtrim(impuestos.CODIGO)+'],0)As [Porcen_')+ Rtrim(impuestos.CODIGO)+']'    "+;
			"	From (   																											"+;
			"	select Distinct convert(Char(5),CODIGO)As CODIGO  from Mtimpu   													"+;
			"		) impuestos   																									"+;
			"		Order by CODIGO 	 																							"+;
			"	select @Consulta_Iva2=coalesce(Rtrim(@Consulta_Iva2)+', isnull(['+Rtrim(impuestos.CODIGO)+'],0)As [Valor_','isnull(['+Rtrim(impuestos.CODIGO)+'],0)As [Valor_')+ Rtrim(impuestos.CODIGO) +']'  			"+;
			"	From (   																											"+;
			"		 select Distinct convert(Char(5),CODIGO)As CODIGO  from Mtimpu    												"+;
			"		) impuestos   																									"+;
			"		Order by CODIGO   																								"+;
			"	select @Base2=coalesce(Rtrim(@Base2)+', [-'+Rtrim(impuestos.CODIGO)+']','[-'+Rtrim(impuestos.CODIGO)+']')   		"+;
			"	From (																												"+;
			"		 select Distinct convert(Char(5),CODIGO)As CODIGO  from Mtimpu      											"+;
			"		) impuestos     																								"+;
			"		Order by CODIGO   																								"+;
			"	select @Porc_Iva2=coalesce(Rtrim(@Porc_Iva2)+', ['+Rtrim(impuestos.CODIGO)+']','['+Rtrim(impuestos.CODIGO)+']')     "+;
			"	From (     																											"+;
			"		 select Distinct convert(Char(5),CODIGO)As CODIGO  from Mtimpu    												"+;
			"		) impuestos     																								"+;
			"		Order by CODIGO  																								"


		mStrSQL2="	Set @TipoDcto = ?pTipoDcto															"+;
			"	Set @NroDcto = ?documentoMostrar 															"+;
			"	Set @Origen = ?pOrigen  																	"+;
			"	set @Sql =  'select '+rTrim(@Total_Base)+', '+rTrim(@Total_Iva)+' 	 						"+;
			"			From(    																			"+;
			"					SELECT   '+Rtrim(@Consulta_Base)+', '+ rTrim(@Consulta_Iva)+' 	 			"+;
			"					FROM(    																	"+;
			"					select codigoimp,   														"+;
			"					mvtradeimpu.porcentaje,  													"+;
			"						sum(case when 	mvtradeimpu.resta=1 then 								"+;
			"						(((mvtrade.Cantidad*mvtrade.ValorUnit)-  (mvtrade.Cantidad*mvtrade.ValorUnit)*(mvtrade.descuento/100) ) *(mvtradeimpu.porcentaje/100*-1))	"+;
			"						else    																																	"+;
			"						(((mvtrade.Cantidad*mvtrade.ValorUnit)-  (mvtrade.Cantidad*mvtrade.ValorUnit)*(mvtrade.descuento/100) ) *(mvtradeimpu.porcentaje/100))	 	"+;
			"					end) as total   															"+;
			"					from MVTRADE 																"+;
			"					inner join mvtradeimpu on mvtrade.idimpuesto=mvtradeimpu.idmvtrade 			"+;
			"					and mvtrade.origen='''+rTrim(@Origen)+'''   								"+;
			"					AND mvtrade.tipodcto='''+rTrim(@TipoDcto)+'''  								"+;
			"					AND mvtrade.nrodcto='''+rTrim(@NroDcto)+'''  								"+;
			"					group by codigoimp,baseiva,  												"+;
			"					mvtradeimpu.porcentaje  													"+;
			"					) As Tabla1 PIVOT    														"+;
			"					(sum(porcentaje)    														"+;
			"					FOR tabla1.codigoimp IN ('+rTrim(@Base)+', '+rTrim(@Porc_Iva)+')  			"+;
			"					) AS PivotTabla   															"+;
			"				UNION  '  																		"+;
			"		set @sql2 =	'SELECT  '+Rtrim(@Consulta_Base2)+', '+ rTrim(@Consulta_Iva2)+' 			"+;
			"					FROM(    																	"+;
			"					select codigoimp,   														"+;
			"					mvtradeimpu.porcentaje,   													"+;
			"						sum(case when 	mvtradeimpu.resta=1 then 								"+;
			"						(((mvtrade.Cantidad*mvtrade.ValorUnit)-  (mvtrade.Cantidad*mvtrade.ValorUnit)*(mvtrade.descuento/100) ) *(mvtradeimpu.porcentaje/100*-1))	"+;
			"						else    																																	"+;
			"						(((mvtrade.Cantidad*mvtrade.ValorUnit)-  (mvtrade.Cantidad*mvtrade.ValorUnit)*(mvtrade.descuento/100) ) *(mvtradeimpu.porcentaje/100)) 		"+;
			"						end) as total   														"+;
			"					from MVTRADE   																"+;
			"					inner join mvtradeimpu on mvtrade.idimpuesto=mvtradeimpu.idmvtrade  		"+;
			"					and mvtrade.origen='''+rTrim(@Origen)+'''    								"+;
			"				    AND mvtrade.tipodcto='''+rTrim(@TipoDcto)+'''    							"+;
			"				    AND mvtrade.nrodcto='''+rTrim(@NroDcto)+'''    								"+;
			"					group by codigoimp,baseiva,   												"+;
			"					mvtradeimpu.porcentaje   													"+;
			"					) As Tabla1 PIVOT (sum(TOTAL)   											"+;
			"					FOR tabla1.codigoimp IN ('+rTrim(@Base2)+', '+rTrim(@Porc_Iva2)+')   		"+;
			"					) AS TablaValorImpuestos    												"+;
			"					) TotalValorImpuestos '    													"+;
			"	exec (@Sql+@sql2)																			"


		mStrSql=mStrSql1+mStrSQL2
		If SQLExec(gConexEmp,mStrSql,"CurImpu")<=0
			oGenerica.Mensajes("No es posible seleccionar los datos de los impuestos")
			Return 0
		Endif
		Select CurImpu

	Endif

********************************************************************
*IMPRIMIR SERIES
* Crear cursor de series que se maneja en el formato de series
* El formato de series es espec�fico y se llama "AnexoSeries.frx"
******************************************************************

* Validar si se selecciono Imprimir series en la captura de series
	If gImprimirSerie

* Se forma el filtro del origen de series segun el origen del documento
		Do Case
* Si es Factura o puntoVenta
		Case pOrigen  = "FAC"
			mFiltroOrigen   = " and S.origen in('DEVVE','VENTA') "

* Si es Compra
		Case pOrigen  = "COM"
			mFiltroOrigen   = " and S.origen in('DEVCO','COMPRA') "

* Si es Inventario, incluye traslados
		Case pOrigen  = "INV"
			mFiltroOrigen   = " and S.origen in('ENTRADA','SALIDA') "

		Endcase

* Query para extraer la informaci�n de series
* Se filtra para los que son COMPRA o DEVOLUCION DE COMPRA que son los asociados al modulo
		mStrSql = 	" Select S.codigo, M.Descripcio, S.serie, S.garantia, " + ;
			"		S.existe, S.origen, S.nrodcto, S.tipodcto, S.bodega, S.codcc, S.ordennro, S.tercero,S.codubica, S.procli " + ;
			"	From mtseries S inner join mtMercia M on S.codigo = M.Codigo " + ;
			"	Where S.NRODCTO = ?documentoMostrar and S.tipoDcto = ?pTipoDcto " +  mFiltroOrigen

		If SQLExec(gConexEmp,mStrSql,"curSeries")<=0
			oGenerica.Mensajes("No es posible seleccionar los datos de las series.")
			Return 0
		Endif

* Usar variable para identificar el tipo de Documento, se usa para mostrar el titulo del formato
		Public gDocumentoOrigen

		Do Case
* Si es Factura
		Case cConsecut.DctoMae = "FA"
			gDocumentoOrigen = "FACTURA DE COMPRA"

* Si es Remisi�n
		Case cConsecut.DctoMae = "RE"
			gDocumentoOrigen = "REMISI�N"

* Si es Nota Cr�dito
		Case cConsecut.DctoMae = "NC"
			gDocumentoOrigen = "NOTA CR�DITO"
		Endcase

	Endif

* Llenar nombre del formato de anexo de series
	mFormatoSeries = "AnexoSeries.frx"

* Verificar que se haya encotrado informacion de series para imprimir y que el formato exista
* Se usa variable mImprimeSerie  para definir si se imprime o no el formato
	If Used("curSeries")
		Select curSeries
		Go Top

		If File(mFormatoSeries) And Reccount() > 0
			mImprimeSerie = .T.
		Else
			mImprimeSerie = .F.
		Endif

		Select curSeries
		Go Top
	Else
		mImprimeSerie = .F.
	Endif


**************************************************************************************************
********************************************************************
***VERSION:  ESTE PROGRAMA SOLO APLICA PARA LA VERSION 2012
******************************************************************
	Select curMvto
	Go Top
	LineasTot = Reccount()
	LineasFal = 19 - LineasTot
	For I = 1 To LineasFal
		Append Blank
		Replace nombre With "Z"
	Next
	Select curEncabezado
	Go Top
	Select curMvto
	Index On Substr(nombre,1,50) To indecom
	Go Top

* Parametros
* 	1. pNombreFormato: Nombre del reporte con formato FRX
*	2. pOrigen : Origen puede ser FAC,INV, COM , CAR, CXP
*	3. pTipoDcto : Tipo de documento
*	4. pDocumentoInicial : Documento inicial
*	5. pDocumentoFinal : Documento Final
* 	6. pTipoSalida Salida por
* 			1. Impresora
*			2. Pantalla
*			3. PDF - Email

* Realizar ciclo para imprimir un Rango

********************************************************************
***VERSION:  ESTE PROGRAMA SOLO APLICA PARA LA VERSION 2012
******************************************************************

	Do Case
* Si es por impresora
	Case pTipoSalida = 1
		For I=1 To pCopias&& Manejo de Copias

			copiaActual=I

			Report Format &pNombreFormato To Printer Noconsole

* Validar si imprime anexo de series
			If mImprimeSerie
* Configurar el cursor de series
				Select curSeries
				Go Top
				Report Format &mFormatoSeries To Printer Noconsole
			Endif
		Next
* Si es por pantalla
	Case pTipoSalida = 2
		Report Format &pNombreFormato Preview

* Validar si imprime anexo de series
		If mImprimeSerie
* Configurar el cursor de series
			Select curSeries
			Go Top
			Report Format &mFormatoSeries Preview
		Endif

* Si es por PDF -email
	Case pTipoSalida = 3
		For I=1 To pCopias && Manejo de Copias
			copiaActual=I

			Do ActivarImpresoraPDF
			Report Format &pNombreFormato To Printer Noconsole

* Validar si imprime anexo de series
			If mImprimeSerie
* Configurar el cursor de series
				Select curSeries
				Go Top
				Do ActivarImpresoraPDF
				Report Format &mFormatoSeries To Printer Noconsole
			Endif
		Next


	Case pTipoSalida = 4

* Parametros : 1. Nombre del Formato
*			   2. .F. Indica que no se muestra por pantalla el PDF

		mArchivoPDF = CrearArchivoPDF(pNombreFormato,.F.)

		If Not Empty(mArchivoPDF)
			mEmailDestino = ObtenerEmail(pNit)
*mEmailDestino = ObtenerEmail(curEncabezado.Nit)
*mEmailDestino="ofima@ofima.com"
			mDetalleCuerpo = "Favor despachar el adjunto de acuerdo con las condiciones conocidas." ;
										  + CHR(13) + CHR(13) + "Por favor registrar sin excepci�n el n�mero de esta orden de compra en el documento de entrega del pedido."
			If Not Empty(mEmailDestino)
				mAsunto = "Pedido Librer�a Lerner "&& + Alltrim(curEncabezado.CliNombre)
				Do EnviaEmailReporte With mEmailDestino,mAsunto,mDetalleCuerpo,mArchivoPDF
				sendEmailToAditionalEmails(pNit, mAsunto, mDetalleCuerpo, mArchivoPDF)

* Enviar E-mail de series
* Validar si imprime anexo de series
				If mImprimeSerie
* Configurar el cursor de series
					Select curSeries
					Go Top
					mArchivoPDFSeries = CrearArchivoPDF(mFormatoSeries,.F.)
					If Not Empty(mArchivoPDFSeries)
						mAsunto = "Pedido Librer�a Lerner " + Alltrim(curEncabezado.CliNombre)
						Do EnviaEmailReporte With mEmailDestino,mAsunto,mDetalleCuerpo,mArchivoPDFSeries					
						sendEmailToAditionalEmails(pNit, mAsunto, mDetalleCuerpo, mArchivoPDFSeries)
					Endif
				Endif
			Else
				Messagebox("El proveedor no tiene eMail configurado, no es posible enviar el correo al proveedor.",64,"Validar")
			Endif
		Else
			Messagebox("El archivo PDF se encuentra vacio",64,"Validar")
		Endif

	Endcase

**** alerta de cambio de precio
	If ((curEncabezado.DctoMae='RE') Or ((curEncabezado.DctoMae='FA' Or curEncabezado.DctoMae='FR') And ;
	(curEncabezado.TipoDcto='F1' OR curEncabezado.TipoDcto='F2' or curEncabezado.TipoDcto='F4'))) 
	

		mStrSQLx = " select ISBN, Titulo, Detalle_Cambio from xvcambiopre_Ler " 
		If SQLExec(gConexEmp,mStrSQLx,"alerta_cambio")<=0
			oGenerica.Mensajes("No es posible seleccionar los datos de alerta para cambio de precio")
			Return 0
		ENDIF
		
		select alerta_cambio
		IF !EOF()
		
		mNombreReporte      = "LERNER_ALERTA_CAMBIO_PRECIO"
		mSPRecalculo     = " "
		mStrSQLCondicion = ""

		DO Opcion With " ExportarReportePlanilla With mNombreReporte,mSPRecalculo,mStrSQLCondicion  "
		
		WAIT WINDOW "REVISE INFORME , PULSE ENTER PARA CONTINUAR "
		
		mStrSQLu = " update mvprecio set  xinformado=0  where xinformado=1 " 
		If SQLExec(gConexEmp,mStrSQLu,"alerta_cambio1")<=0
			oGenerica.Mensajes("No es posible actualizar los datos de mvprecio")
			Return 0
		ENDIF
		
			
		endif
		
	Endif

	Select curMvto
	Use

	Select curEncabezado
	Use


* Si usa el cursor de series cerrarlo
	If Used("curSeries")
		Select curSeries
		Use
	Endif

	pDocumentoInicial = pDocumentoInicial + 1

Enddo

Function ObtenerEmail
Parameters pNit


mEmailEnviar = ""

mStrSql1="select dctomae from tipodcto where dctomae=?pTipoDcto"
If SQLExec(gConexEmp,mStrSql1,'cLista')<=0
	oGenerica.Mensajes("No se ejecuto la conexi�n a la tabla TipoDcto")
Endif
*!*	Select cLista
*!*	Go Top
*!*	If !Eof()
*!*		mEsRQ=cLista.DctoMae
*!*	Else
*!*		mEsRQ=""
*!*	Endif


*!*	If mEsRQ=""

		mStrSql = " Select Mtprocli.Nit As Nit,Mtprocli.Emailp As emailp,' ' as EMAILP2 "+;
		" From Mtprocli Where Mtprocli.ESPROVEE='S' And Mtprocli.Nit=?pNit "
		_CLIPTEXT = mStrSql
*!*	Else

*!*	   		mstrsql =   " Select Mtnitres.Nitasigna As Nit,Mtnitres.Email As emailp "+;
*!*	              " From  Mtnitres Where Mtnitres.Nitasigna=?mNitResponsableRQ "

*!*		mStrSql=" SELECT Mtnitres.Nitasigna AS Nit "+;
*!*			",Mtnitres.Email AS emailp "+;
*!*			",MTPROCLI.EMAILP AS EMAILP2 "+;
*!*			" FROM Mtnitres "+;
*!*			" INNER JOIN MTPROCLI ON MTPROCLI.NIT = MTNITRES.NITASIGNA "+;
*!*			" WHERE Mtnitres.Nitasigna =?mNitResponsableRQ "
*!*		mStrSql = "SELECT MTNITRES.NITASIGNA AS NIT, MTNITRES.EMAILP AS EMAILP FROM MTNITRES WHERE Mtnitres.Nitasigna = ?mNitResponsableRQ"

*!*	Endif

If SQLExec(gConexEmp,mStrSql,"curDatos")<=0
	oGenerica.Mensajes("No es posible seleccionar los datos de email")
	Return ""
Endif
Select curDatos
Go Top

*!*	If mEsRQ <> "" And (Empty(curDatos.EMAILP) And curDatos.emailp2 <> "")
*!*		mEmailEnviar =curDatos.emailp2
*!*	Endif


*!*	If mEsRQ <> "" And (!Empty(curDatos.EMAILP) And curDatos.emailp2="")
*!*		mEmailEnviar =curDatos.EMAILP
*!*	Endif

*!*	If mEsRQ <> "" And (!Empty(curDatos.EMAILP) And curDatos.emailp2<>"")
*!*		mEmailEnviar =curDatos.EMAILP
*!*	Endif

*!*	If mEsRQ <> "" And (Empty(curDatos.EMAILP) And curDatos.emailp2="")
*!*		mEmailEnviar =""
*!*	Endif

mEmailEnviar = curDatos.EMAILP


If Empty(mEmailEnviar)
	mEmailEnviar = Inputbox("El Nit/Responsable: "+Alltrim(pNit)+" no tiene correo asociado. Ingrese un correo para continuar ","Verificar Nit ")
Endif



Return mEmailEnviar

*---------------------------------------------------

FUNCTION sendEmailToAditionalEmails(pNit, mAsunto, mDetalleCuerpo, mArchivoPDF)

LOCAL lcEmails, lcEmailCopia

lcSqlQuery = "SELECT XEMAIL1, XEMAIL2, XEMAIL3 FROM MTPROCLI WHERE NIT = '" + TRANSFORM(pNit) + "'"

IF SQLEXEC(gConexEmp, lcSqlQuery, "lcEmails") <= 0
		oGenerica.Mensajes("No se pudo obtener los datos de email adicionales para el NIT " + ALLTRIM(TRANSFORM(pNit)))
	RETURN ""
ENDIF

IF !EMPTY(lcEmails.XEMAIL1) OR lcEmails.XEMAIL1 != ""
	Do EnviaEmailReporte With lcEmails.XEMAIL1,mAsunto,mDetalleCuerpo,mArchivoPDF
ENDIF

IF !EMPTY(lcEmails.XEMAIL2) OR lcEmails.XEMAIL2 != ""
	Do EnviaEmailReporte With lcEmails.XEMAIL2,mAsunto,mDetalleCuerpo,mArchivoPDF
ENDIF

IF !EMPTY(lcEmails.XEMAIL3) OR lcEmails.XEMAIL3 != ""
	Do EnviaEmailReporte With lcEmails.XEMAIL3,mAsunto,mDetalleCuerpo,mArchivoPDF
ENDIF

lcSqlQuery = "SELECT VALOR FROM MTGLOBAL WHERE CAMPO = 'EMAILCOPIARQ'"

IF SQLEXEC(gConexEmp, lcSqlQuery, "lcEmailCopia") <= 0
		oGenerica.Mensajes("No se pudo obtener los datos de email copia para la empresa")
	RETURN ""
ENDIF

IF !EMPTY(lcEmailCopia.VALOR) OR lcEmailCopia.VALOR != ""
	Do EnviaEmailReporte With lcEmailCopia.VALOR,mAsunto,mDetalleCuerpo,mArchivoPDF
ENDIF

ENDFUNC
