-- sekwencje
CREATE SEQUENCE lekarze_id
start with 1
increment by 1;

CREATE SEQUENCE pielegniarki_id
start with 1
increment by 1;

--zarzadzanie pracownikami
CREATE OR REPLACE PACKAGE Pracownicy
  IS
    PROCEDURE DodajLekarza(
		vImie VARCHAR, 
		vNazwisko VARCHAR, 
		vTelefon VARCHAR, 
		vSpecjalizacja VARCHAR, 
		vOddzial VARCHAR);
	
	PROCEDURE DodajPielegniarka(
		vImie VARCHAR, 
		vNazwisko VARCHAR, 
		vTelefon VARCHAR, 
		vOddzial VARCHAR);
	
	PROCEDURE UsunLekarza(
		vId NUMBER);
	
	PROCEDURE UsunPielegniarke(
		vId NUMBER);
	
	PROCEDURE PrzypiszSpecjalizacje(
		vNazwisko VARCHAR, 
		vSpecjalizacja VARCHAR);
	
	PROCEDURE DodajSpecjalizacje(
		vNazwa VARCHAR);
	
	PROCEDURE UsunSpecjalizacje(
		vNazwa VARCHAR);
	
	FUNCTION OddzialLekarzId(
		vId NUMBER
	)RETURN VARCHAR;
	
	FUNCTION OddzialPielegniarkaId(
		vId NUMBER
	)RETURN VARCHAR;
	
    FUNCTION NazwiskoLekarz(
		vId NUMBER
	)RETURN VARCHAR;
	
    FUNCTION NazwiskoPielegniarka(
		vId NUMBER
	)RETURN VARCHAR;
	
END Pracownicy;

CREATE OR REPLACE PACKAGE BODY Pracownicy IS

	PROCEDURE DodajLekarza(
		vImie VARCHAR, 
		vNazwisko VARCHAR, 
		vTelefon VARCHAR, 
		vSpecjalizacja VARCHAR, 
		vOddzial VARCHAR
	)IS
		vId NUMBER;

		BEGIN
			vId := lekarze_id.nextval;
			insert into Lekarze
			values(vId, vImie, vNazwisko, vTelefon, vSpecjalizacja, vOddzial);
	END DodajLekarza;

	PROCEDURE DodajPielegniarka(
		vImie VARCHAR, 
		vNazwisko VARCHAR, 
		vTelefon VARCHAR, 
		vOddzial VARCHAR
	)IS
		vId NUMBER;
	
		BEGIN
			vId := pielegniarki_id.nextval;
			insert into Lekarze
			values(vId, vImie, vNazwisko, vTelefon, vOddzial);
	END DodajPielegniarka;

	PROCEDURE UsunLekarza(
		vId NUMBER
	)IS
		BEGIN
			delete from Lekarze where id_lekarza = vId;
	END UsunLekarza;

	PROCEDURE UsunPielegniarke(
		vId NUMBER
	)IS
		BEGIN
			delete from Pielegniarki where id_pielegniarki = vId;
	END UsunPielegniarke;

	PROCEDURE PROCEDURE PrzypiszSpecjalizacje(
		vNazwisko VARCHAR, 
		vSpecjalizacja VARCHAR
	)IS
		BEGIN
			UPDATE Lekarze
			SET specjalizacja = vSpecjalizacja
			WHERE nazwisko like vNazwisko;
	END PrzypiszSpecjalizacje;

	PROCEDURE DodajSpecjalizacje(
		vNazwa VARCHAR
	)IS
		BEGIN
			insert into Specjalizacje
			values(vNazwa);
	END DodajSpecjalizacje;

	PROCEDURE UsunSpecjalizacje(
		vNazwa VARCHAR
	)IS
		BEGIN
			delete from Specjalizacje
			where nazwa = vNazwa;
	END UsunSpecjalizacje;

	FUNCTION OddzialLekarzId(
		vId NUMBER
	)RETURN VARCHAR IS
		vWynik VARCHAR;
			BEGIN
				select oddzial
				into vWynik
				from Lekarze
				where id_lekarza like vId;
				RETURN vWynik;
	END OddzialLekarzId;

	FUNCTION OddzialPielegniarkaId(
		vId NUMBER
	)RETURN VARCHAR IS
		vWynik VARCHAR;
			BEGIN
				select oddzial
				into vWynik
				from Pielegniarki
				where id_pielegniarki like vId;
				RETURN vWynik;
	END OddzialPielegniarkaId;

	FUNCTION NazwiskoLekarz(
		vId NUMBER
	)RETURN VARCHAR IS
		vWynik VARCHAR;
		BEGIN
			select nazwisko
			into vWynik
			from Lekarze
			where id_lekarza like vId;
			RETURN vWynik;
	END NazwiskoLekarz;

	FUNCTION NazwiskoPielegniarka(
		vId NUMBER
	)RETURN VARCHAR IS
		vWynik VARCHAR;
		BEGIN
			select nazwisko
			into vWynik
			from Pielegniarki
			where id_pielegniarki like vId;
			RETURN vWynik;
	END NazwiskoPielegniarka;
END Pracownicy;

--zarzadzanie sprzetem
CREATE OR REPLACE PACKAGE Sprzety
  IS
    PROCEDURE DodajSprzet(
		vNrSeryjny VARCHAR, 
		nazwa VARCHAR, producent VARCHAR, 
		rok_produkcji DATE, 
		vOddzial VARCHAR);
		
	PROCEDURE UsunSprzet(
		vNrSeryjny VARCHAR);
		
	PROCEDURE PrzeniesSprzet(
		vNrSeryjny VARCHAR, 
		vOddzial VARCHAR);
		
	FUNCTION OddzialSprzet(
		vNrSeryjny VARCHAR
	)RETURN VARCHAR;
	
	FUNCTION NazwaSprzet(
		vNrSeryjny VARCHAR
	)RETURN VARCHAR;
	
END Sprzety;

CREATE OR REPLACE PACKAGE BODY Sprzety IS
	PROCEDURE DodajSprzet(
		vNrSeryjny VARCHAR, 
		nazwa VARCHAR, 
		producent VARCHAR, 
		rok_produkcji DATE, 
		vOddzial VARCHAR
	)IS
		BEGIN
			insert into Sprzety
			values(vNrSeryjny, nazwa, producent, rok_produkcji, vOddzial);
	END DodajSprzet;

	PROCEDURE UsunSprzet(
		vNrSeryjny VARCHAR
	)IS
		BEGIN
			delete from Sprzety where numer_seryjny = vNrSeryjny;
	END UsunSprzet;

	PROCEDURE PROCEDURE PrzeniesSprzet(
		vNrSeryjny VARCHAR, 
		vOddzial VARCHAR
	)IS
		BEGIN
			UPDATE Sprzety
			SET nazwa_oddzialu = vOddzial
			WHERE numer_seryjny like vNrSeryjny;
	END PrzeniesSprzet;

	FUNCTION OddzialSprzet(
		vNrSeryjny VARCHAR
	)RETURN VARCHAR IS
		vWynik VARCHAR;
		BEGIN
			select nazwa_oddzialu
			into vWynik
			from Sprzety
			where numer_seryjny like vNrSeryjny;
			RETURN vWynik;
	END OddzialSprzet;

	FUNCTION NazwaSprzet(
		vNrSeryjny VARCHAR
	)RETURN VARCHAR IS
		vWynik VARCHAR;
		BEGIN
			select nazwa
			into vWynik
			from Sprzety
			where numer_seryjny like vNrSeryjny;
			RETURN vWynik;
	END NazwaSprzet;
END Sprzety;

--zarzadzanie oddzialami i salami
CREATE OR REPLACE PACKAGE Odzialy
  IS
    PROCEDURE DodajOddzial(
		vNazwa VARCHAR, 
		vOpis VARCHAR);
		
	PROCEDURE DodajSale(
		vNumer NUMBER, 
		vPietro NUMBER, 
		vOddzial VARCHAR);
		
	PROCEDURE ZamknijOddzial(
		vNazwa VARCHAR);
		
	PROCEDURE ZamknijSale(
		vNumer NUMBER);
		
	FUNCTION PietroSali(
		vNumer NUMBER
	)RETURN NUMERIC;
	
	FUNCTION OpisOddzialu(
		vNazwa VARCHAR
	)RETURN VARCHAR;
	
END Odzialy;

CREATE OR REPLACE PACKAGE BODY Odzialy IS
	PROCEDURE DodajOddzial(
		vNazwa VARCHAR, 
		vOpis VARCHAR default NULL
	)IS
	    BEGIN
			insert into Oddzialy
			values(vNazwa, vOpis);
	END DodajOddzial;

	PROCEDURE DodajSale(
		vNumer NUMBER, 
		vPietro NUMBER, 
		vOddzial VARCHAR
		)IS
			BEGIN
				insert into Sale
				values(vNumer, vPietro, vOddzial);
	END DodajSale;

	PROCEDURE ZamknijOddzial(
		vNazwa VARCHAR
	)IS
		BEGIN
			delete from Oddzialy where nazwa = vNazwa;
	END ZamknijOddzial;

	PROCEDURE ZamknijSale(
		vNumer NUMBER
	)IS
		BEGIN
			delete from Sale where numer = vNumer;
	END ZamknijSale;

	FUNCTION PietroSali(
		vNumer NUMBER
	)RETURN NUMERIC IS
		vWynik VARCHAR;
		BEGIN
			select pietro
			into vWynik
			from Sale
			where numer like vNumer;
			RETURN vWynik;
	END PietroSali;

	FUNCTION OpisOddzialu(
		vNazwa VARCHAR
	)RETURN VARCHAR IS
		vWynik VARCHAR;
		BEGIN
			select opis
			into vWynik
			from Oddzialy
			where nazwa like vNazwa;
			RETURN vWynik;
	END OpisOddzialu;
END Odzialy;

--zarzadzanie Pacjentami
CREATE OR REPLACE PACKAGE Chorzy
  IS
    PROCEDURE PrzyjeciePacjenta(
		vImie VARCHAR, 
		vNazwisko VARCHAR, 
		vDataUr date, 
		vPesel VARCHAR, 
		vUlica VARCHAR, 
		vMiasto VARCHAR, 
		vKodPoczt VARCHAR, 
		vTelefon VARCHAR, 
		vLekarz NUMBER, 
		vSala NUMBER);
		
	PROCEDURE WypiszPacjenta(
		vPesel VARCHAR);
		
	PROCEDURE ZmienSale(
		vPesel VARCHAR, 
		vSala NUMBER);	
		
	FUNCTION SprawdzOddzial(
		vPesel VARCHAR
	)RETURN VARCHAR;
	
	FUNCTION SprawdzSale(
		vPesel VARCHAR
	)RETURN NUMERIC;
	
	FUNCTION LekarzProwadzacy(
		vPesel VARCHAR
	)RETURN NUMERIC;
END Chorzy;

CREATE OR REPLACE PACKAGE BODY Chorzy IS
	PROCEDURE PrzyjeciePacjenta(
		vImie VARCHAR, 
		vNazwisko VARCHAR, 
		vDataUr date, 
		vPesel VARCHAR, 
		vUlica VARCHAR, 
		vMiasto VARCHAR, 
		vKodPoczt VARCHAR, 
		vTelefon VARCHAR, 
		vLekarz NUMBER, 
		vSala NUMBER
	)IS
		BEGIN
			insert into Pacjenci
			values(vImie, vNazwisko, vDataUr, vPesel, vUlica, vMiasto, vKodPoczt, vTelefon);
			insert into Przyjecia
			values(current_timestamp, vLekarz, vPesel, vSala)
	END PrzyjeciePacjenta;

	PROCEDURE WypiszPacjenta(
		vPesel VARCHAR
	)IS
		BEGIN
			delete from Przyjecia where pacjent = vPesel;
			delete from Pacjenci where pesel = vPesel;
	END WypiszPacjenta;

	PROCEDURE ZmienSale(
		vPesel VARCHAR, 
		vSala NUMBER
	)IS
		BEGIN
			UPDATE Przyjecia
			SET nr_sali = vSala
			WHERE pacjent like vPesel;
	END ZmienSale;
	
	FUNCTION SprawdzOddzial(
		vPesel VARCHAR
	)RETURN VARCHAR IS
		vWynik VARCHAR;
		vSala NUMBER;
		BEGIN
			select nr_sali
			into vSala
			from Przyjecia
			where pacjent like vPesel;
			
			select oddzial
			into vWynik
			from Sale
			where numer = vSala
			RETURN vWynik;
	END SprawdzOddzial;

	FUNCTION SprawdzSale(
		vPesel VARCHAR
	)RETURN NUMERIC IS
		vWynik VARCHAR;
		BEGIN
			select nr_sali
			into vWynik
			from Przyjecia
			where pacjent like vPesel;
			RETURN vWynik;
	END SprawdzSale;

	FUNCTION LekarzProwadzacy(
		vPesel VARCHAR
	)RETURN NUMERIC IS
		vWynik VARCHAR;
		BEGIN
			select lekarz
			into vWynik
			from Przyjecia
			where pacjent like vPesel;
			RETURN vWynik;
	END LekarzProwadzacy;
END Chorzy;