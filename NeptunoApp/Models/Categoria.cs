namespace NeptunoApp.Models;

public sealed class Categoria
{
    public int CategoriaID { get; set; }
    public string NombreCategoria { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public bool Activo { get; set; } = true;

    public Categoria() { }
    public Categoria(int id, string nombre)
    {
        CategoriaID = id;
        NombreCategoria = nombre;
        Activo = true;
    }
}
