DECLARE @include_tSQLt_build INT = ISNULL( TRY_CAST('${tSQLt}' AS INT), 0 ) ;

IF (@include_tSQLt_build = 0)
BEGIN
    EXEC tSQLt.Uninstall ;
END ;
ELSE
BEGIN
    EXEC tSQLt.NewTestClass @ClassName = N'tSQLt_tsqlcron' ; -- nvarchar(max)
END ;
