using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
var connectionString = builder.Configuration.GetConnectionString("Shop")
    ?? "Server=db,1433;Database=ShopDb;User Id=sa;Password=Shop_example_2026!;Encrypt=True;TrustServerCertificate=True;";

builder.Services.AddDbContext<ShopDbContext>(options => options.UseSqlServer(connectionString));
var app = builder.Build();

// The API retries while SQL Server completes its first-time startup.
for (var attempt = 1; ; attempt++)
{
    try
    {
        await using var scope = app.Services.CreateAsyncScope();
        var database = scope.ServiceProvider.GetRequiredService<ShopDbContext>();
        await database.Database.EnsureCreatedAsync();
        if (!await database.Products.AnyAsync())
        {
            database.Products.AddRange(
                new Product { Name = "Everyday Backpack", Description = "A durable companion for commutes and weekend escapes.", Price = 64.00m, Emoji = "🎒" },
                new Product { Name = "Studio Headphones", Description = "Comfortable wireless sound for work, travel, and downtime.", Price = 129.00m, Emoji = "🎧" },
                new Product { Name = "Ceramic Pour-over Set", Description = "A simple ritual for a better cup of coffee.", Price = 42.50m, Emoji = "☕" },
                new Product { Name = "Desk Light", Description = "Warm, focused light with a clean modern silhouette.", Price = 79.00m, Emoji = "💡" }
            );
            await database.SaveChangesAsync();
        }
        break;
    }
    catch when (attempt < 30)
    {
        Console.WriteLine($"Waiting for SQL Server (attempt {attempt}/30)...");
        await Task.Delay(TimeSpan.FromSeconds(2));
    }
}

app.MapGet("/api/health", () => Results.Ok(new { status = "healthy" }));

app.MapGet("/api/products", async (ShopDbContext database) =>
    await database.Products.AsNoTracking()
        .Select(product => new ProductResponse(product.Id, product.Name, product.Description, product.Price, product.Emoji))
        .ToListAsync());

app.MapPost("/api/orders", async Task<IResult> (CreateOrderRequest request, ShopDbContext database) =>
{
    if (string.IsNullOrWhiteSpace(request.CustomerName) || string.IsNullOrWhiteSpace(request.Email) || request.Items.Count == 0)
        return Results.BadRequest(new { message = "Name, email, and at least one item are required." });

    var productIds = request.Items.Select(item => item.ProductId).Distinct().ToArray();
    var products = await database.Products.Where(product => productIds.Contains(product.Id)).ToDictionaryAsync(product => product.Id);
    if (products.Count != productIds.Length || request.Items.Any(item => item.Quantity is < 1 or > 20 || !products.ContainsKey(item.ProductId)))
        return Results.BadRequest(new { message = "The cart contains an invalid product or quantity." });

    var order = new Order
    {
        CustomerName = request.CustomerName.Trim(),
        Email = request.Email.Trim(),
        CreatedAt = DateTime.UtcNow,
        Items = request.Items.Select(item => new OrderItem
        {
            ProductId = item.ProductId,
            Quantity = item.Quantity,
            UnitPrice = products[item.ProductId].Price
        }).ToList()
    };
    order.Total = order.Items.Sum(item => item.UnitPrice * item.Quantity);
    database.Orders.Add(order);
    await database.SaveChangesAsync();
    return Results.Created($"/api/orders/{order.Id}", new { order.Id, order.Total, order.CreatedAt });
});

app.Run();

public sealed class ShopDbContext(DbContextOptions<ShopDbContext> options) : DbContext(options)
{
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>().Property(product => product.Price).HasPrecision(10, 2);
        modelBuilder.Entity<Order>().Property(order => order.Total).HasPrecision(10, 2);
        modelBuilder.Entity<OrderItem>().Property(item => item.UnitPrice).HasPrecision(10, 2);
        modelBuilder.Entity<OrderItem>().HasOne(item => item.Product).WithMany().HasForeignKey(item => item.ProductId);
        modelBuilder.Entity<OrderItem>().HasOne(item => item.Order).WithMany(order => order.Items).HasForeignKey(item => item.OrderId);
    }
}

public sealed class Product
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public required string Description { get; set; }
    public decimal Price { get; set; }
    public required string Emoji { get; set; }
}

public sealed class Order
{
    public int Id { get; set; }
    public required string CustomerName { get; set; }
    public required string Email { get; set; }
    public DateTime CreatedAt { get; set; }
    public decimal Total { get; set; }
    public List<OrderItem> Items { get; set; } = [];
}

public sealed class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public Order? Order { get; set; }
    public int ProductId { get; set; }
    public Product? Product { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
}

public sealed record ProductResponse(int Id, string Name, string Description, decimal Price, string Emoji);
public sealed record OrderLineRequest(int ProductId, int Quantity);
public sealed record CreateOrderRequest(string CustomerName, string Email, List<OrderLineRequest> Items);
