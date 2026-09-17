IF DB_ID(N'NeptunoDB') IS NULL CREATE DATABASE NeptunoDB;
GO
USE NeptunoDB;
GO

IF OBJECT_ID(N'dbo.Categorias', N'U') IS NULL
CREATE TABLE dbo.Categorias (
    CategoriaID INT IDENTITY(1,1) PRIMARY KEY,
    NombreCategoria NVARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(200) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Categorias_Activo DEFAULT 1
);
ELSE IF COL_LENGTH(N'dbo.Categorias', N'Activo') IS NULL
ALTER TABLE dbo.Categorias ADD Activo BIT NOT NULL CONSTRAINT DF_Categorias_Activo DEFAULT 1;
GO

IF OBJECT_ID(N'dbo.Proveedores', N'U') IS NULL
CREATE TABLE dbo.Proveedores (
    ProveedorID INT IDENTITY(1,1) PRIMARY KEY,
    CompaniaNombre NVARCHAR(60) NOT NULL,
    NombreContacto NVARCHAR(40) NULL,
    CargoContacto NVARCHAR(40) NULL,
    Direccion NVARCHAR(80) NULL,
    Ciudad NVARCHAR(30) NULL,
    CodigoPostal NVARCHAR(10) NULL,
    Pais NVARCHAR(30) NULL,
    Telefono NVARCHAR(24) NULL,
    Fax NVARCHAR(24) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Proveedores_Activo DEFAULT 1
);
ELSE IF COL_LENGTH(N'dbo.Proveedores', N'Activo') IS NULL
ALTER TABLE dbo.Proveedores ADD Activo BIT NOT NULL CONSTRAINT DF_Proveedores_Activo DEFAULT 1;
GO

IF OBJECT_ID(N'dbo.Clientes', N'U') IS NULL
CREATE TABLE dbo.Clientes (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Empresa NVARCHAR(60) NOT NULL,
    NombreContacto NVARCHAR(40) NULL,
    Ciudad NVARCHAR(30) NULL,
    Pais NVARCHAR(30) NULL,
    Telefono NVARCHAR(24) NULL
);
GO

IF OBJECT_ID(N'dbo.Empleados', N'U') IS NULL
CREATE TABLE dbo.Empleados (
    EmpleadoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(20) NOT NULL,
    Apellidos NVARCHAR(30) NOT NULL,
    Cargo NVARCHAR(40) NULL,
    FechaNacimiento DATE NULL,
    FechaContratacion DATE NULL,
    Ciudad NVARCHAR(30) NULL,
    Pais NVARCHAR(30) NULL
);
GO

IF OBJECT_ID(N'dbo.Transportistas', N'U') IS NULL
CREATE TABLE dbo.Transportistas (
    TransportistaID INT IDENTITY(1,1) PRIMARY KEY,
    CompaniaNombre NVARCHAR(60) NOT NULL,
    Telefono NVARCHAR(24) NULL
);
GO

IF OBJECT_ID(N'dbo.Productos', N'U') IS NULL
CREATE TABLE dbo.Productos (
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,
    NombreProducto NVARCHAR(60) NOT NULL,
    ProveedorID INT NULL,
    CategoriaID INT NULL,
    CantidadPorUnidad NVARCHAR(30) NULL,
    PrecioUnidad DECIMAL(10,2) NOT NULL CONSTRAINT DF_Productos_Precio DEFAULT 0,
    UnidadesEnExistencia SMALLINT NOT NULL CONSTRAINT DF_Productos_Existencia DEFAULT 0,
    UnidadesEnPedido SMALLINT NOT NULL CONSTRAINT DF_Productos_Pedido DEFAULT 0,
    NivelDeReorden SMALLINT NOT NULL CONSTRAINT DF_Productos_Reorden DEFAULT 0,
    Descontinuado BIT NOT NULL CONSTRAINT DF_Productos_Descontinuado DEFAULT 0,
    Activo BIT NOT NULL CONSTRAINT DF_Productos_Activo DEFAULT 1,
    CONSTRAINT FK_Productos_Proveedores FOREIGN KEY (ProveedorID) REFERENCES dbo.Proveedores(ProveedorID),
    CONSTRAINT FK_Productos_Categorias FOREIGN KEY (CategoriaID) REFERENCES dbo.Categorias(CategoriaID)
);
ELSE IF COL_LENGTH(N'dbo.Productos', N'Activo') IS NULL
ALTER TABLE dbo.Productos ADD Activo BIT NOT NULL CONSTRAINT DF_Productos_Activo DEFAULT 1;
GO

IF OBJECT_ID(N'dbo.Pedidos', N'U') IS NULL
CREATE TABLE dbo.Pedidos (
    PedidoID INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID INT NULL,
    EmpleadoID INT NULL,
    FechaPedido DATE NOT NULL,
    FechaRequerida DATE NULL,
    FechaEnvio DATE NULL,
    TransportistaID INT NULL,
    Destinatario NVARCHAR(60) NULL,
    CiudadDestino NVARCHAR(30) NULL,
    PaisDestino NVARCHAR(30) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Pedidos_Activo DEFAULT 1,
    CONSTRAINT FK_Pedidos_Clientes FOREIGN KEY (ClienteID) REFERENCES dbo.Clientes(ClienteID),
    CONSTRAINT FK_Pedidos_Empleados FOREIGN KEY (EmpleadoID) REFERENCES dbo.Empleados(EmpleadoID),
    CONSTRAINT FK_Pedidos_Transportistas FOREIGN KEY (TransportistaID) REFERENCES dbo.Transportistas(TransportistaID)
);
ELSE IF COL_LENGTH(N'dbo.Pedidos', N'Activo') IS NULL
ALTER TABLE dbo.Pedidos ADD Activo BIT NOT NULL CONSTRAINT DF_Pedidos_Activo DEFAULT 1;
GO

IF OBJECT_ID(N'dbo.DetallePedidos', N'U') IS NULL
CREATE TABLE dbo.DetallePedidos (
    PedidoID INT NOT NULL,
    ProductoID INT NOT NULL,
    PrecioUnidad DECIMAL(10,2) NOT NULL,
    Cantidad SMALLINT NOT NULL DEFAULT 1,
    Descuento DECIMAL(4,2) NOT NULL DEFAULT 0,
    CONSTRAINT PK_DetallePedidos PRIMARY KEY (PedidoID, ProductoID),
    CONSTRAINT FK_DetallePedidos_Pedidos FOREIGN KEY (PedidoID) REFERENCES dbo.Pedidos(PedidoID),
    CONSTRAINT FK_DetallePedidos_Productos FOREIGN KEY (ProductoID) REFERENCES dbo.Productos(ProductoID)
);
GO

-- Datos iniciales si las tablas están vacías
IF NOT EXISTS (SELECT 1 FROM dbo.Categorias)
INSERT dbo.Categorias (NombreCategoria, Descripcion, Activo) VALUES
(N'Bebidas', N'Refrescos, cafés, tés, cervezas y otras bebidas', 1),
(N'Condimentos', N'Salsas, especias y aderezos', 1),
(N'Confituras', N'Mermeladas, dulces y postres', 1),
(N'Lácteos', N'Quesos y otros productos lácteos', 1),
(N'Carnes y Embutidos', N'Carnes preparadas y embutidos', 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Proveedores)
INSERT dbo.Proveedores (CompaniaNombre, NombreContacto, CargoContacto, Direccion, Ciudad, CodigoPostal, Pais, Telefono, Fax, Activo) VALUES
(N'Lácteos García S.A.', N'Ana García', N'Gerente de Ventas', N'Av. Los Álamos 245', N'Lima', N'15024', N'Perú', N'511-4567890', N'511-4567891', 1),
(N'Bebidas del Sur Ltda.', N'Carlos Ramírez', N'Jefe Comercial', N'Jr. Comercio 890', N'Arequipa', N'04001', N'Perú', N'054-223344', N'054-223345', 1),
(N'Embutidos La Preferida', N'María Torres', N'Coordinadora de Distribución', N'Calle Las Flores 120', N'Trujillo', N'13001', N'Perú', N'044-556677', N'044-556678', 1),
(N'Condimentos Andinos SAC', N'Jorge Quispe', N'Gerente General', N'Av. Industrial 500', N'Cusco', N'08001', N'Perú', N'084-778899', N'084-778900', 1),
(N'Dulces del Valle E.I.R.L.', N'Lucía Fernández', N'Encargada de Ventas', N'Jr. San Martín 77', N'Chiclayo', N'14001', N'Perú', N'074-991122', N'074-991123', 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Productos)
INSERT dbo.Productos (NombreProducto, ProveedorID, CategoriaID, CantidadPorUnidad, PrecioUnidad, UnidadesEnExistencia, UnidadesEnPedido, NivelDeReorden, Descontinuado, Activo) VALUES
(N'Café Andino Premium', 2, 1, N'500 g', 45.90, 120, 30, 20, 0, 1),
(N'Salsa de Ají Amarillo', 4, 2, N'300 ml', 12.50, 200, 50, 30, 0, 1),
(N'Mermelada de Aguaymanto', 5, 3, N'250 g', 15.00, 80, 20, 15, 0, 1),
(N'Queso Fresco Andino', 1, 4, N'1 kg', 22.00, 60, 10, 10, 0, 1),
(N'Chorizo Ahumado', 3, 5, N'500 g', 18.75, 90, 25, 20, 0, 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Clientes)
INSERT dbo.Clientes (Empresa, NombreContacto, Ciudad, Pais, Telefono) VALUES
(N'Comercial Andina SAC', N'Pedro Salazar', N'Lima', N'Perú', N'511-2345678'),
(N'Supermercados del Norte', N'Rosa Medina', N'Trujillo', N'Perú', N'044-334455'),
(N'Distribuidora Sureña EIRL', N'Luis Chávez', N'Arequipa', N'Perú', N'054-667788'),
(N'Minimarket Central', N'Elena Rojas', N'Cusco', N'Perú', N'084-112233'),
(N'Tiendas Express SAC', N'Miguel Ángel Paredes', N'Chiclayo', N'Perú', N'074-445566');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Empleados)
INSERT dbo.Empleados (Nombre, Apellidos, Cargo, FechaNacimiento, FechaContratacion, Ciudad, Pais) VALUES
(N'Juan', N'Pérez Gómez', N'Vendedor', '1990-05-12', '2020-01-15', N'Lima', N'Perú'),
(N'María', N'López Díaz', N'Supervisora de Ventas', '1988-09-23', '2018-03-01', N'Lima', N'Perú'),
(N'Carlos', N'Ruiz Mendoza', N'Vendedor', '1992-02-17', '2021-06-10', N'Arequipa', N'Perú'),
(N'Sofía', N'Vargas Castro', N'Gerente Regional', '1985-11-30', '2015-08-20', N'Trujillo', N'Perú'),
(N'Diego', N'Fernández Ríos', N'Vendedor', '1995-07-08', '2022-02-01', N'Cusco', N'Perú');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Transportistas)
INSERT dbo.Transportistas (CompaniaNombre, Telefono) VALUES
(N'Transportes Rápido SAC', N'511-8889900'),
(N'Envíos Seguros EIRL', N'511-7776655'),
(N'Logística del Pacífico', N'054-990011'),
(N'Courier Nacional SA', N'044-223344'),
(N'TransAndino Express', N'084-556677');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Pedidos)
INSERT dbo.Pedidos (ClienteID, EmpleadoID, FechaPedido, FechaRequerida, FechaEnvio, TransportistaID, Destinatario, CiudadDestino, PaisDestino, Activo) VALUES
(1, 1, '2026-08-10', '2026-08-20', '2026-08-15', 1, N'Comercial Andina SAC', N'Lima', N'Perú', 1),
(2, 3, '2026-08-12', '2026-08-22', '2026-08-18', 3, N'Supermercados del Norte', N'Trujillo', N'Perú', 1),
(3, 2, '2026-08-15', '2026-08-25', NULL, 4, N'Distribuidora Sureña EIRL', N'Arequipa', N'Perú', 1),
(4, 4, '2026-08-30', '2026-08-30', '2026-08-26', 5, N'Minimarket Central', N'Cusco', N'Perú', 1),
(5, 5, '2026-08-22', '2026-09-01', '2026-08-28', 2, N'Tiendas Express SAC', N'Chiclayo', N'Perú', 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.DetallePedidos)
INSERT dbo.DetallePedidos (PedidoID, ProductoID, PrecioUnidad, Cantidad, Descuento) VALUES
(1, 1, 45.90, 10, 0),
(2, 2, 12.50, 25, 0.05),
(3, 3, 15.00, 15, 0),
(4, 4, 22.00, 8, 0.10),
(5, 5, 18.75, 12, 0);
GO
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
