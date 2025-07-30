using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;
// using GeneratedModels;

var builder = Host.CreateApplicationBuilder(args);

//Add configuration from environment variables
builder.Configuration.AddEnvironmentVariables();

// Register DbContext with MySQL
// var connectionString = builder.Configuration["DEV_CONNECTION_STRING"] ?? 
//                       builder.Configuration["PROD_CONNECTION_STRING"] ??
//                       "server=localhost;port=3306;database=myapp;uid=root;pwd=YourPassword";

// builder.Services.AddDbContext<ScaffoldedContext>(options =>
//     options.UseMySQL(connectionString));

var host = builder.Build();

Console.WriteLine("Application configured with Entity Framework!");
// Console.WriteLine($"Using connection: {connectionString.Replace("pwd=", "pwd=***")}");

// Keep the application running
await host.RunAsync();
