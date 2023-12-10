CREATE TABLE Aerodromi (
	AerodromID SERIAL PRIMARY KEY,
	Naziv VARCHAR(255),
	Grad VARCHAR(255),
	KapacitetPiste INT,
	KapacitetSkladista INT
);

CREATE TABLE Avioni (
	AvionID SERIAL PRIMARY KEY,
	Naziv VARCHAR(255),
	Model VARCHAR(255),
	Kapacitet INT,
	Status VARCHAR(50)
);

CREATE TABLE Korisnici (
	UserID SERIAL PRIMARY KEY,
	Ime VARCHAR(255),
	LoyaltyKartica BOOLEAN,
	BrojKupljenihKarata INT
);

CREATE TABLE Karte (
	KartaID SERIAL PRIMARY KEY,
	UserID INT REFERENCES Korisnici(UserID),
	LetID INT REFERENCES Letovi(LetID),
	Cijena DECIMAL(10, 2),
	Mjesto VARCHAR(10)
);

CREATE TABLE Letovi (
	LetID SERIAL PRIMARY KEY,
	AvionID INT REFERENCES Avioni(AvionID),
	PolazniAerodromID INT REFERENCES Aerodromi(AerodromID),
	DolazniAerodromID INT REFERENCES Aerodromi(AerodromID),
	DatumPolaska DATE,
	DatumDolaska DATE,
	Ocjena INT,
	Komentar TEXT
);

ALTER TABLE Letovi
ADD COLUMN OsobljeID INT REFERENCES Osoblje(OsobljeID);

CREATE OR REPLACE FUNCTION check_crew_per_flight()
RETURNS BOOLEAN AS $$
DECLARE
    crew_count INT;
BEGIN
    SELECT COUNT(*) INTO crew_count
    FROM Osoblje AS O
    JOIN Letovi AS L ON O.OsobljeID = L.OsobljeID
    WHERE (
        (O.Vrsta = 'Pilot' AND L.PilotID = O.OsobljeID) OR
        (O.Vrsta = 'Stjuardesa' AND L.StjuardesaID = O.OsobljeID)
    ) AND (
        (L.DatumPolaska <= NEW.DatumPolaska AND L.DatumDolaska >= NEW.DatumPolaska) OR
        (L.DatumPolaska <= NEW.DatumDolaska AND L.DatumDolaska >= NEW.DatumDolaska)
    );

    RETURN crew_count = 0;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE Letovi
ADD CONSTRAINT UniqueCrewPerFlight
CHECK (check_crew_per_flight());

ALTER TABLE Letovi
ADD CONSTRAINT CheckRating
CHECK (Ocjena >= 1 AND Ocjena <= 5);

CREATE TABLE Osoblje (
	OsobljeID SERIAL PRIMARY KEY,
	Ime VARCHAR(255),
	Prezime VARCHAR(255),
	Vrsta VARCHAR(50),
	Godine INT,
	BrojOdradenihLetova INT,
	Placa DECIMAL(10, 2)
);

ALTER TABLE Osoblje
ADD CONSTRAINT CheckPilotAge
CHECK (Vrsta = 'Pilot' AND Godine >= 20 AND Godine <= 60)

