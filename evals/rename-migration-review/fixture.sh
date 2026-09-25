#!/usr/bin/env bash
set -euo pipefail
mkdir -p Migrations
cat > Migrations/20260901_RenameEmail.cs <<'CS'
public partial class RenameEmail : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(name: "Email", table: "Users");
        migrationBuilder.AddColumn<string>(name: "EmailAddress", table: "Users",
            type: "text", nullable: false, defaultValue: "");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(name: "EmailAddress", table: "Users");
        migrationBuilder.AddColumn<string>(name: "Email", table: "Users",
            type: "text", nullable: true);
    }
}
CS
