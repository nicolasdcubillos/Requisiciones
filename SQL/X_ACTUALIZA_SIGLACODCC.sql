
CREATE Procedure X_ACTUALIZA_SIGLACODCC
-- Se declaran los parámetros de actualización	
	( 
	@pSigla Varchar (5),
	@pGrupo Varchar (60),
	@PCodcc Varchar (20),
	@pEliminar Bit 
	)

As Begin


-- Inicia transacción
Begin Try 
	If @pEliminar = 1
	Begin
		-- Valida integridad referencial
		Execute DBO.OF_SP_ValidarForeingkey X_SIGLAUBICA,@pSigla		
	End	
	-----------------------------------------------------------------------------------	
	-- Corre las rutinas de eliminación, actualización e inserción
	-- Eliminación
	If @pEliminar = 1 
		Begin
			Delete X_SIGLAUBICA Where Sigla = @pSigla
		End	
	Else 
		Begin
		-- Actualización
		If  Exists(Select Sigla  From X_SIGLAUBICA  Where Sigla = @pSigla)
			Begin
				Update X_SIGLAUBICA Set  GRUPO = @pGrupo,Codcc=@PCodcc  Where Sigla = @psigla 
			End
		-- Inserción
		Else
			Begin		
				Insert  X_SIGLAUBICA (Sigla,grupo,codcc,Eliminar) 	
						Values	(@pSigla,@pGrupo,@PCodcc,0)	
			End 	
		End
	-----------------------------------------------------------------------------------			
-- Finaliza transacción
End Try


--- Recolección de errores 
BEGIN CATCH

	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		
	IF @ErrorMessage='Error de integridad'
		BEGIN
			Raiserror('No se puede Eliminar un registro que tenga relacion con otra tabla',11,1)
		END
	ELSE
		BEGIN
			Exec ofsp_ObtenerInformacionError 'No es posible ejecutar procedimiento almacenado de X_ACTUALIZA_SIGLACODCC '
		END
END CATCH
End