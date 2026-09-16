USE NeptunoDB;
GO

/* =========================================================
   LABORATORIO 05 - PROCEDIMIENTOS ALMACENADOS
   ENFOQUE: ExecuteNonQuery y Eliminación Lógica (Activo = 0)
   ========================================================= */

/* ---------------------------------------------------------
   CATÁLOGOS AUXILIARES
   --------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ClienteID, Empresa FROM dbo.Clientes ORDER BY Empresa;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Empleado_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EmpleadoID, RTRIM(Nombre) + ' ' + RTRIM(Apellidos) AS NombreCompleto 
    FROM dbo.Empleados ORDER BY Apellidos, Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Transportista_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TransportistaID, CompaniaNombre FROM dbo.Transportistas ORDER BY CompaniaNombre;
END
GO

/* ---------------------------------------------------------
   1. CRUD DE CATEGORÍAS (Baja lógica: Activo = 0)
   --------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CategoriaID, NombreCategoria, Descripcion, Activo 
    FROM dbo.Categorias 
    WHERE Activo = 1
    ORDER BY NombreCategoria;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Crear
    @NombreCategoria NVARCHAR(30),
    @Descripcion NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NULLIF(LTRIM(RTRIM(@NombreCategoria)), N'') IS NULL 
        THROW 51101, N'El nombre de categoría es obligatorio.', 1;

    INSERT INTO dbo.Categorias (NombreCategoria, Descripcion, Activo)
    VALUES (LTRIM(RTRIM(@NombreCategoria)), NULLIF(LTRIM(RTRIM(@Descripcion)), N''), 1);

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS CategoriaID;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Actualizar
    @CategoriaID INT,
    @NombreCategoria NVARCHAR(30),
    @Descripcion NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NULLIF(LTRIM(RTRIM(@NombreCategoria)), N'') IS NULL 
        THROW 51102, N'El nombre de categoría es obligatorio.', 1;

    UPDATE dbo.Categorias
    SET NombreCategoria = LTRIM(RTRIM(@NombreCategoria)),
        Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), N'')
    WHERE CategoriaID = @CategoriaID;

    IF @@ROWCOUNT = 0
        THROW 51103, N'La categoría no existe o no se pudo actualizar.', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Eliminar
    @CategoriaID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Eliminación lógica (Soft Delete): actualización de estado a inactivo
    UPDATE dbo.Categorias
    SET Activo = 0
    WHERE CategoriaID = @CategoriaID;

    IF @@ROWCOUNT = 0
        THROW 51104, N'La categoría no existe o ya se encuentra inactiva.', 1;
END
GO

/* ---------------------------------------------------------
   2. CRUD Y BÚSQUEDA DE PROVEEDORES (Baja lógica: Activo = 0)
   --------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProveedorID, CompaniaNombre, NombreContacto, CargoContacto, 
           Direccion, Ciudad, CodigoPostal, Pais, Telefono, Fax, Activo
    FROM dbo.Proveedores
    WHERE Activo = 1
    ORDER BY CompaniaNombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Buscar
    @NombreContacto NVARCHAR(40) = NULL,
    @Ciudad NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @NombreContacto = NULLIF(LTRIM(RTRIM(@NombreContacto)), N'');
    SET @Ciudad = NULLIF(LTRIM(RTRIM(@Ciudad)), N'');

    SELECT ProveedorID, CompaniaNombre, NombreContacto, CargoContacto, 
           Direccion, Ciudad, CodigoPostal, Pais, Telefono, Fax, Activo
    FROM dbo.Proveedores
    WHERE Activo = 1
      AND (@NombreContacto IS NULL OR NombreContacto LIKE N'%' + @NombreContacto + N'%')
      AND (@Ciudad IS NULL OR Ciudad LIKE N'%' + @Ciudad + N'%')
    ORDER BY CompaniaNombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Crear
    @CompaniaNombre NVARCHAR(60),
    @NombreContacto NVARCHAR(40) = NULL,
    @CargoContacto NVARCHAR(40) = NULL,
    @Direccion NVARCHAR(80) = NULL,
    @Ciudad NVARCHAR(30) = NULL,
    @CodigoPostal NVARCHAR(10) = NULL,
    @Pais NVARCHAR(30) = NULL,
    @Telefono NVARCHAR(24) = NULL,
    @Fax NVARCHAR(24) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NULLIF(LTRIM(RTRIM(@CompaniaNombre)), N'') IS NULL
        THROW 51201, N'La compañía proveedora es obligatoria.', 1;

    INSERT INTO dbo.Proveedores (CompaniaNombre, NombreContacto, CargoContacto, Direccion, Ciudad, CodigoPostal, Pais, Telefono, Fax, Activo)
    VALUES (LTRIM(RTRIM(@CompaniaNombre)), NULLIF(@NombreContacto, N''), NULLIF(@CargoContacto, N''),
            NULLIF(@Direccion, N''), NULLIF(@Ciudad, N''), NULLIF(@CodigoPostal, N''),
            NULLIF(@Pais, N''), NULLIF(@Telefono, N''), NULLIF(@Fax, N''), 1);

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS ProveedorID;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Actualizar
    @ProveedorID INT,
    @CompaniaNombre NVARCHAR(60),
    @NombreContacto NVARCHAR(40) = NULL,
    @CargoContacto NVARCHAR(40) = NULL,
    @Direccion NVARCHAR(80) = NULL,
    @Ciudad NVARCHAR(30) = NULL,
    @CodigoPostal NVARCHAR(10) = NULL,
    @Pais NVARCHAR(30) = NULL,
    @Telefono NVARCHAR(24) = NULL,
    @Fax NVARCHAR(24) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NULLIF(LTRIM(RTRIM(@CompaniaNombre)), N'') IS NULL
        THROW 51202, N'La compañía proveedora es obligatoria.', 1;

    UPDATE dbo.Proveedores
    SET CompaniaNombre = LTRIM(RTRIM(@CompaniaNombre)),
        NombreContacto = NULLIF(@NombreContacto, N''),
        CargoContacto = NULLIF(@CargoContacto, N''),
        Direccion = NULLIF(@Direccion, N''),
        Ciudad = NULLIF(@Ciudad, N''),
        CodigoPostal = NULLIF(@CodigoPostal, N''),
        Pais = NULLIF(@Pais, N''),
        Telefono = NULLIF(@Telefono, N''),
        Fax = NULLIF(@Fax, N'')
    WHERE ProveedorID = @ProveedorID;

    IF @@ROWCOUNT = 0
        THROW 51203, N'El proveedor no existe o no se pudo actualizar.', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Eliminar
    @ProveedorID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Eliminación lógica (Soft Delete): actualización de estado a inactivo
    UPDATE dbo.Proveedores
    SET Activo = 0
    WHERE ProveedorID = @ProveedorID;

    IF @@ROWCOUNT = 0
        THROW 51204, N'El proveedor no existe o ya se encuentra inactivo.', 1;
END
GO

/* ---------------------------------------------------------
   3. CRUD DE PRODUCTOS (Baja lógica: Activo = 0)
   --------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_Producto_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.ProductoID, p.NombreProducto, p.ProveedorID, p.CategoriaID, p.CantidadPorUnidad,
           p.PrecioUnidad, p.UnidadesEnExistencia, p.UnidadesEnPedido, p.NivelDeReorden, 
           p.Descontinuado, p.Activo,
           c.NombreCategoria, pr.CompaniaNombre AS NombreProveedor
    FROM dbo.Productos p
    LEFT JOIN dbo.Categorias c ON c.CategoriaID = p.CategoriaID
    LEFT JOIN dbo.Proveedores pr ON pr.ProveedorID = p.ProveedorID
    WHERE p.Activo = 1
    ORDER BY p.NombreProducto;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_ObtenerPorId
    @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductoID, NombreProducto, ProveedorID, CategoriaID, CantidadPorUnidad,
           PrecioUnidad, UnidadesEnExistencia, UnidadesEnPedido, NivelDeReorden, 
           Descontinuado, Activo
    FROM dbo.Productos
    WHERE ProductoID = @ProductoID;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Crear
    @NombreProducto NVARCHAR(60),
    @ProveedorID INT = NULL,
    @CategoriaID INT = NULL,
    @CantidadPorUnidad NVARCHAR(30) = NULL,
    @PrecioUnidad DECIMAL(10,2) = 0,
    @UnidadesEnExistencia SMALLINT = 0,
    @UnidadesEnPedido SMALLINT = 0,
    @NivelDeReorden SMALLINT = 0,
    @Descontinuado BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF NULLIF(LTRIM(RTRIM(@NombreProducto)), N'') IS NULL 
        THROW 51001, N'El nombre del producto es obligatorio.', 1;
    IF @PrecioUnidad < 0 OR @UnidadesEnExistencia < 0 OR @UnidadesEnPedido < 0 OR @NivelDeReorden < 0 
        THROW 51002, N'Los valores numéricos no pueden ser negativos.', 1;

    INSERT INTO dbo.Productos (NombreProducto, ProveedorID, CategoriaID, CantidadPorUnidad, 
                               PrecioUnidad, UnidadesEnExistencia, UnidadesEnPedido, NivelDeReorden, Descontinuado, Activo)
    VALUES (LTRIM(RTRIM(@NombreProducto)), @ProveedorID, @CategoriaID, 
            NULLIF(LTRIM(RTRIM(@CantidadPorUnidad)), N''), @PrecioUnidad, 
            @UnidadesEnExistencia, @UnidadesEnPedido, @NivelDeReorden, @Descontinuado, 1);

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS ProductoID;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Actualizar
    @ProductoID INT,
    @NombreProducto NVARCHAR(60),
    @ProveedorID INT = NULL,
    @CategoriaID INT = NULL,
    @CantidadPorUnidad NVARCHAR(30) = NULL,
    @PrecioUnidad DECIMAL(10,2) = 0,
    @UnidadesEnExistencia SMALLINT = 0,
    @UnidadesEnPedido SMALLINT = 0,
    @NivelDeReorden SMALLINT = 0,
    @Descontinuado BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF NULLIF(LTRIM(RTRIM(@NombreProducto)), N'') IS NULL 
        THROW 51003, N'El nombre del producto es obligatorio.', 1;
    IF @PrecioUnidad < 0 OR @UnidadesEnExistencia < 0 OR @UnidadesEnPedido < 0 OR @NivelDeReorden < 0 
        THROW 51004, N'Los valores numéricos no pueden ser negativos.', 1;

    UPDATE dbo.Productos
    SET NombreProducto = LTRIM(RTRIM(@NombreProducto)),
        ProveedorID = @ProveedorID,
        CategoriaID = @CategoriaID,
        CantidadPorUnidad = NULLIF(LTRIM(RTRIM(@CantidadPorUnidad)), N''),
        PrecioUnidad = @PrecioUnidad,
        UnidadesEnExistencia = @UnidadesEnExistencia,
        UnidadesEnPedido = @UnidadesEnPedido,
        NivelDeReorden = @NivelDeReorden,
        Descontinuado = @Descontinuado
    WHERE ProductoID = @ProductoID;

    IF @@ROWCOUNT = 0 
        THROW 51005, N'El producto no existe o no se pudo actualizar.', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Eliminar
    @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Eliminación lógica (Soft Delete): actualización de estado a inactivo
    UPDATE dbo.Productos
    SET Activo = 0
    WHERE ProductoID = @ProductoID;

    IF @@ROWCOUNT = 0 
        THROW 51006, N'El producto no existe o ya se encuentra inactivo.', 1;
END
GO

/* ---------------------------------------------------------
   4. CRUD DE PEDIDOS (Baja lógica: Activo = 0)
   --------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.PedidoID, p.ClienteID, p.EmpleadoID, p.FechaPedido, p.FechaRequerida, p.FechaEnvio,
           p.TransportistaID, p.Destinatario, p.CiudadDestino, p.PaisDestino, p.Activo,
           cl.Empresa AS NombreCliente,
           RTRIM(e.Nombre) + ' ' + RTRIM(e.Apellidos) AS NombreEmpleado,
           t.CompaniaNombre AS NombreTransportista,
           ISNULL((SELECT SUM(dp.PrecioUnidad * dp.Cantidad * (1.0 - dp.Descuento)) 
                   FROM dbo.DetallePedidos dp WHERE dp.PedidoID = p.PedidoID), 0.0) AS Total
    FROM dbo.Pedidos p
    LEFT JOIN dbo.Clientes cl ON cl.ClienteID = p.ClienteID
    LEFT JOIN dbo.Empleados e ON e.EmpleadoID = p.EmpleadoID
    LEFT JOIN dbo.Transportistas t ON t.TransportistaID = p.TransportistaID
    WHERE p.Activo = 1
    ORDER BY p.FechaPedido DESC, p.PedidoID DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Crear
    @ClienteID INT = NULL,
    @EmpleadoID INT = NULL,
    @FechaPedido DATE,
    @FechaRequerida DATE = NULL,
    @FechaEnvio DATE = NULL,
    @TransportistaID INT = NULL,
    @Destinatario NVARCHAR(60) = NULL,
    @CiudadDestino NVARCHAR(30) = NULL,
    @PaisDestino NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @FechaPedido IS NULL 
        THROW 51301, N'La fecha del pedido es obligatoria.', 1;

    INSERT INTO dbo.Pedidos (ClienteID, EmpleadoID, FechaPedido, FechaRequerida, FechaEnvio, 
                             TransportistaID, Destinatario, CiudadDestino, PaisDestino, Activo)
    VALUES (@ClienteID, @EmpleadoID, @FechaPedido, @FechaRequerida, @FechaEnvio, 
            @TransportistaID, NULLIF(LTRIM(RTRIM(@Destinatario)), N''), 
            NULLIF(LTRIM(RTRIM(@CiudadDestino)), N''), NULLIF(LTRIM(RTRIM(@PaisDestino)), N''), 1);

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS PedidoID;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Actualizar
    @PedidoID INT,
    @ClienteID INT = NULL,
    @EmpleadoID INT = NULL,
    @FechaPedido DATE,
    @FechaRequerida DATE = NULL,
    @FechaEnvio DATE = NULL,
    @TransportistaID INT = NULL,
    @Destinatario NVARCHAR(60) = NULL,
    @CiudadDestino NVARCHAR(30) = NULL,
    @PaisDestino NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @FechaPedido IS NULL 
        THROW 51302, N'La fecha del pedido es obligatoria.', 1;

    UPDATE dbo.Pedidos
    SET ClienteID = @ClienteID,
        EmpleadoID = @EmpleadoID,
        FechaPedido = @FechaPedido,
        FechaRequerida = @FechaRequerida,
        FechaEnvio = @FechaEnvio,
        TransportistaID = @TransportistaID,
        Destinatario = NULLIF(LTRIM(RTRIM(@Destinatario)), N''),
        CiudadDestino = NULLIF(LTRIM(RTRIM(@CiudadDestino)), N''),
        PaisDestino = NULLIF(LTRIM(RTRIM(@PaisDestino)), N'')
    WHERE PedidoID = @PedidoID;

    IF @@ROWCOUNT = 0
        THROW 51303, N'El pedido no existe o no se pudo actualizar.', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Eliminar
    @PedidoID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Eliminación lógica (Soft Delete): actualización de estado a inactivo
    UPDATE dbo.Pedidos
    SET Activo = 0
    WHERE PedidoID = @PedidoID;

    IF @@ROWCOUNT = 0
        THROW 51304, N'El pedido no existe o ya se encuentra inactivo.', 1;
END
GO

/* ---------------------------------------------------------
   5. REPORTE DE DETALLES DE PEDIDO CON INNER JOIN Y FECHAS
      Excluye pedidos inactivos (Activo = 0)
   --------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_DetallePedido_ListarPorRangoFechas
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        p.PedidoID,
        p.FechaPedido,
        ISNULL(cl.Empresa, N'Consumidor Final') AS NombreCliente,
        pr.NombreProducto,
        dp.PrecioUnidad,
        dp.Cantidad,
        dp.Descuento,
        CONVERT(DECIMAL(10,2), (dp.PrecioUnidad * dp.Cantidad) * (1.0 - dp.Descuento)) AS Subtotal
    FROM dbo.DetallePedidos dp
    INNER JOIN dbo.Pedidos p ON p.PedidoID = dp.PedidoID
    INNER JOIN dbo.Productos pr ON pr.ProductoID = dp.ProductoID
    LEFT JOIN dbo.Clientes cl ON cl.ClienteID = p.ClienteID
    LEFT JOIN dbo.Categorias c ON c.CategoriaID = pr.CategoriaID
    WHERE p.Activo = 1  -- Excluye pedidos con Activo = 0
      AND pr.Activo = 1 -- Excluye productos con Activo = 0
      AND (@FechaInicio IS NULL OR p.FechaPedido >= @FechaInicio)
      AND (@FechaFin IS NULL OR p.FechaPedido <= @FechaFin)
    ORDER BY p.FechaPedido DESC, p.PedidoID, pr.NombreProducto;
END
GO
