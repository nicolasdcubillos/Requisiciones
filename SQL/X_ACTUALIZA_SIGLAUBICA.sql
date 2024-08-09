CREATE Procedure [dbo].[X_ACTUALIZA_SIGLAUBICA]
(
	@pCodUbica VarChar (20),
	@pSigla	VarChar(20)
)
As

--Comienza Control de Error
Begin Try 

	UPDATE MTUBICA
		set SIGLA=RTRIM(@pSigla)
		where  CODUBICA =RTRIM(@pCodUbica)

End Try
----Atrapa los errores
Begin Catch 	
	-- Ejecutar Sp que muestra informacion del error
	Exec ofsp_ObtenerInformacionError 'No es posible ejecutar procedimiento almacenado  X_ACTUALIZA_SIGLAUBICA'
End Catch



