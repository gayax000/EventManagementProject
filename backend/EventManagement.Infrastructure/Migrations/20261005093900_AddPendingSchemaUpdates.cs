using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EventManagement.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPendingSchemaUpdates : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
                ALTER TABLE ""Vendors"" ADD COLUMN IF NOT EXISTS ""PackageName"" text;
                ALTER TABLE ""Vendors"" ADD COLUMN IF NOT EXISTS ""PackagePrice"" numeric;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""AssignedVendorsJson"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""CateringStyle"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""CustomPrompt"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""EventSession"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""PreferredLocation"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""RevisionNotes"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""TableRefreshmentsJson"" text;
                CREATE TABLE IF NOT EXISTS ""Notifications"" (
                    ""NotificationId"" uuid NOT NULL CONSTRAINT ""PK_Notifications"" PRIMARY KEY,
                    ""UserId"" uuid NOT NULL REFERENCES ""Users"" (""UserId"") ON DELETE CASCADE,
                    ""EventId"" uuid NULL REFERENCES ""Events"" (""EventId""),
                    ""Title"" character varying(200) NOT NULL,
                    ""Message"" text NOT NULL,
                    ""Type"" character varying(50) NOT NULL,
                    ""IsRead"" boolean NOT NULL DEFAULT false,
                    ""CreatedAt"" timestamp with time zone NOT NULL DEFAULT NOW()
                );
                CREATE INDEX IF NOT EXISTS ""IX_Notifications_EventId"" ON ""Notifications"" (""EventId"");
                CREATE INDEX IF NOT EXISTS ""IX_Notifications_UserId"" ON ""Notifications"" (""UserId"");
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
                DROP TABLE IF EXISTS ""Notifications"";
                ALTER TABLE ""Vendors"" DROP COLUMN IF EXISTS ""PackageName"";
                ALTER TABLE ""Vendors"" DROP COLUMN IF EXISTS ""PackagePrice"";
                ALTER TABLE ""Events"" DROP COLUMN IF EXISTS ""AssignedVendorsJson"";
                ALTER TABLE ""Events"" DROP COLUMN IF EXISTS ""CateringStyle"";
                ALTER TABLE ""Events"" DROP COLUMN IF EXISTS ""CustomPrompt"";
                ALTER TABLE ""Events"" DROP COLUMN IF EXISTS ""EventSession"";
                ALTER TABLE ""Events"" DROP COLUMN IF EXISTS ""PreferredLocation"";
                ALTER TABLE ""Events"" DROP COLUMN IF EXISTS ""RevisionNotes"";
                ALTER TABLE ""Events"" DROP COLUMN IF EXISTS ""TableRefreshmentsJson"";
            ");
        }
    }
}
