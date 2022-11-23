-- Sample database for a data modelling lesson, everything is using a swedish naming style.
USE master;
GO
IF db_id('minaAdresser') IS NOT NULL DROP DATABASE minaAdresser;
CREATE DATABASE minaAdresser;
GO
USE minaAdresser;
GO
CREATE SCHEMA Tabeller;
GO
CREATE SCHEMA Adresser;
GO
CREATE TABLE Tabeller.Namn
 (
  NamnID int IDENTITY(1,1) NOT NULL
   CONSTRAINT pk_Tabeller_Namn
   PRIMARY KEY CLUSTERED,
  Namn nvarchar(255) NOT NULL
   CONSTRAINT uq_Tabeller_Namn_Namn
   UNIQUE
 )
CREATE TABLE Tabeller.Adresser_Adress
 (
  AdressID  int IDENTITY(1,1) NOT NULL
   CONSTRAINT pk_Adresser_Adress
   PRIMARY KEY CLUSTERED,
  Förnamn int NOT NULL
   CONSTRAINT fk_Adresser_Adress_Förnamn
   FOREIGN KEY REFERENCES Tabeller.Namn(NamnID),
  Efternamn int NOT NULL
   CONSTRAINT fk_Adresser_Adress_Efternamn
   FOREIGN KEY REFERENCES Tabeller.Namn(NamnID),
  Gata int NOT NULL
   CONSTRAINT fk_Adresser_Adress_Gata
   FOREIGN KEY REFERENCES Tabeller.Namn(NamnID),
  Gatunummer nchar(15) NOT NULL
   CONSTRAINT df_Adresser_Adress_Gatunummer
   DEFAULT (''),
  Postnummer char(6) NOT NULL
   CONSTRAINT ck_Adresser_Adress_Postnummer
   CHECK (Postnummer LIKE '[1-9][0-9][0-9] [0-9][0-9]'),
  Ort int NOT NULL
   CONSTRAINT fk_Adresser_Adress_Ort
   FOREIGN KEY REFERENCES Tabeller.Namn(NamnID)
 )
GO
CREATE VIEW Adresser.Adress
AS
SELECT
 a.AdressID,
 f.Namn AS Förnamn,
 e.Namn AS Efternamn,
 g.Namn AS Gata,
 a.Gatunummer,
 a.Postnummer,
 o.Namn AS Ort
FROM Tabeller.Adresser_Adress a
INNER JOIN Tabeller.Namn f ON a.Förnamn = f.NamnID
INNER JOIN Tabeller.Namn e ON a.Efternamn = e.NamnID
INNER JOIN Tabeller.Namn g ON a.Gata  = g.NamnID
INNER JOIN Tabeller.Namn o ON a.Ort  = o.NamnID
GO
CREATE VIEW Adresser.Utskrift
AS
SELECT
 a.AdressID,
 f.Namn + ' ' + e.Namn    AS Mottagare,
 g.Namn + ' ' + a.Gatunummer   AS Postadress,
 a.Postnummer + ' ' + UPPER(o.Namn) AS Postort
FROM Tabeller.Adresser_Adress a
INNER JOIN Tabeller.Namn f ON a.Förnamn = f.NamnID
INNER JOIN Tabeller.Namn e ON a.Efternamn = e.NamnID
INNER JOIN Tabeller.Namn g ON a.Gata  = g.NamnID
INNER JOIN Tabeller.Namn o ON a.Ort  = o.NamnID
GO
CREATE FUNCTION Adresser.hämtaNamn(@NamnID int)
RETURNS nvarchar(255)
AS
BEGIN
RETURN(SELECT Namn FROM Tabeller.Namn WHERE NamnID = @NamnID)
END
GO
CREATE FUNCTION Adresser.hämtaNamnID(@Namn nvarchar(255))
RETURNS int
AS
BEGIN
RETURN(SELECT NamnID FROM Tabeller.Namn WHERE Namn = @Namn)
END
GO
CREATE PROCEDURE Adresser.skapaNamn @Namn nvarchar(255), @NamnID int OUTPUT
AS
BEGIN
DECLARE @Retur int = 0
IF @Namn IS NULL
BEGIN
 SET @Namn = ''
 SET @Retur += 10
END
SET @NamnID = Adresser.hämtaNamnID(@Namn)
IF @NamnID IS NULL
BEGIN
 INSERT INTO Tabeller.Namn(Namn) VALUES(@Namn)
 SET @NamnID = SCOPE_IDENTITY()
 SET @Retur += 1
END
RETURN @Retur
END
GO
CREATE PROCEDURE Adresser.uppdateraAdress
 @Förnamn nvarchar(255),
 @Efternamn nvarchar(255),
 @Gata nvarchar(255),
 @Gatunummer nvarchar(255),
 @Postnummer nvarchar(255),
 @Ort nvarchar(255),
 @AdressID int OUTPUT,
 @updateAdressID int = -1
AS
BEGIN
DECLARE
 @Retur int = 0,
 @Exec int = 0,
 @FörnamnID int,
 @EfternamnID int,
 @GataID int,
 @OrtID int
IF @Postnummer NOT LIKE '[1-9][0-9][0-9] [0-9][0-9]' SET @Retur = -3
ELSE IF @Gatunummer IS NULL SET @Retur = -2
ELSE
BEGIN
EXEC @Exec = Adresser.skapaNamn @Förnamn, @FörnamnID OUTPUT
IF @exec != 0
BEGIN
 SET @Retur += @Exec * 10
 SET @Exec = 0
END
EXEC @Exec = Adresser.skapaNamn @Efternamn, @EfternamnID OUTPUT
IF @exec != 0
BEGIN
 SET @Retur += @Exec * 1000
 SET @Exec = 0
END
EXEC @Exec = Adresser.skapaNamn @Gata, @GataID OUTPUT
IF @exec != 0
BEGIN
 SET @Retur += @Exec * 100000
 SET @Exec = 0
END
EXEC @Exec = Adresser.skapaNamn @Ort, @OrtID OUTPUT
IF @exec != 0
BEGIN
 SET @Retur += @Exec * 10000000
 SET @Exec = 0
END
END
IF @Retur >= 0
BEGIN
IF @updateAdressID = -1
BEGIN
SELECT @AdressID = AdressID FROM Tabeller.Adresser_Adress
WHERE
 Förnamn = @FörnamnID
AND Efternamn = @EfternamnID
AND Gata = @GataID
AND Gatunummer = @Gatunummer
AND Postnummer = @Postnummer
AND Ort = @OrtID
IF @AdressID IS NULL
BEGIN
INSERT INTO Tabeller.Adresser_Adress(Förnamn, Efternamn, Gata, Gatunummer, Postnummer, Ort)
VALUES(@FörnamnID, @EfternamnID, @GataID, @Gatunummer, @Postnummer, @OrtID)
SET @AdressID = SCOPE_IDENTITY()
SET @Retur += 1
END
END
ELSE
BEGIN
DECLARE @updated TABLE (AdressID int)
UPDATE Tabeller.Adresser_Adress
SET
 Förnamn = @FörnamnID,
 Efternamn = @EfternamnID,
 Gata = @GataID,
 Gatunummer = @Gatunummer,
 Postnummer = @Postnummer,
 Ort = @OrtID
OUTPUT inserted.AdressID INTO @updated
WHERE AdressID = @updateAdressID
SELECT @AdressID = AdressID FROM @updated WHERE AdressID = @updateAdressID
SET @Retur += 2
END
END
RETURN @Retur
END
GO
USE master
