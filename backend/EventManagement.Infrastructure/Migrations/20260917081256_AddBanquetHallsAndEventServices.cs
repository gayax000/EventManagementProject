using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EventManagement.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddBanquetHallsAndEventServices : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "BanquetHallId",
                table: "Events",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EventType",
                table: "Events",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "SelectedServicesJson",
                table: "Events",
                type: "text",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "BanquetHalls",
                columns: table => new
                {
                    BanquetHallId = table.Column<Guid>(type: "uuid", nullable: false),
                    VenueId = table.Column<Guid>(type: "uuid", nullable: false),
                    HallName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    MaxCapacity = table.Column<int>(type: "integer", nullable: false),
                    HallRentalPrice = table.Column<decimal>(type: "numeric", nullable: false),
                    PerPlatePrice = table.Column<decimal>(type: "numeric", nullable: false),
                    IsOutdoor = table.Column<bool>(type: "boolean", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BanquetHalls", x => x.BanquetHallId);
                    table.ForeignKey(
                        name: "FK_BanquetHalls_Venues_VenueId",
                        column: x => x.VenueId,
                        principalTable: "Venues",
                        principalColumn: "VenueId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Events_BanquetHallId",
                table: "Events",
                column: "BanquetHallId");

            migrationBuilder.CreateIndex(
                name: "IX_BanquetHalls_VenueId",
                table: "BanquetHalls",
                column: "VenueId");

            migrationBuilder.AddForeignKey(
                name: "FK_Events_BanquetHalls_BanquetHallId",
                table: "Events",
                column: "BanquetHallId",
                principalTable: "BanquetHalls",
                principalColumn: "BanquetHallId",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Events_BanquetHalls_BanquetHallId",
                table: "Events");

            migrationBuilder.DropTable(
                name: "BanquetHalls");

            migrationBuilder.DropIndex(
                name: "IX_Events_BanquetHallId",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "BanquetHallId",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "EventType",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "SelectedServicesJson",
                table: "Events");
        }
    }
}
