-- sekwencje
CREATE SEQUENCE lekarze_id
start with 1
increment by 1;

CREATE SEQUENCE pielegniarki_id
start with 1
increment by 1;

CREATE SEQUENCE wyniki_id
start with 1
increment by 1;

CREATE SEQUENCE badania_id
start with 1
increment by 1;

--zarzadzanie pracownikami
CREATE OR REPLACE PACKAGE PracownicySzpitala
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
	
	exBlednyOddzial EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBlednyOddzial, -20001);

	exBlednaSpecjalizacja EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBlednaSpecjalizacja, -20002);

	exBledneIdLekarz EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBledneIdLekarz, -20003);

	exBledneIdPielegniarka EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBledneIdPielegniarka, -20004);

	exPosiadaJuzSpecjalizacje EXCEPTION;
	PRAGMA EXCEPTION_INIT(exPosiadaJuzSpecjalizacje, -20005);

	exIstniejeSpecjalizacja EXCEPTION;
	PRAGMA EXCEPTION_INIT(exIstniejeSpecjalizacja, -20006);

	exBrakSpecjalizacji EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBrakSpecjalizacji, -20007);
	
END PracownicySzpitala;

CREATE OR REPLACE PACKAGE BODY PracownicySzpitala IS

	PROCEDURE DodajLekarza(
		vImie VARCHAR, 
		vNazwisko VARCHAR, 
		vTelefon VARCHAR, 
		vSpecjalizacja VARCHAR, 
		vOddzial VARCHAR
	)IS
		vId NUMBER;
		vIloscOdd NUMBER;
		vIloscSpec NUMBER;
		BEGIN
			
			SELECT count(*) into vIloscOdd 
			from oddzialy 
			where nazwa = vOddzial;
			
			if vIloscOdd = 0 then
				RAISE exBlednyOddzial;
			end if;

			SELECT count(*) into vIloscSpec 
			from Specjalizacje 
			where nazwa = vSpecjalizacja;
		
			if vSpecjalizacja <> NULL and vIloscSpec = 0 then
				RAISE exBlednaSpecjalizacja;
			end if;
			
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
		vIloscOdd NUMBER;
		BEGIN
		
			SELECT count(*) into vIloscOdd 
			from oddzialy
			where nazwa = vOddzial;
			
			if vIloscOdd = 0 then
				RAISE exBlednyOddzial;
			end if;
		
			vId := pielegniarki_id.nextval;
			insert into Pielegniarki
			values(vId, vImie, vNazwisko, vTelefon, vOddzial);
	END DodajPielegniarka;

	PROCEDURE UsunLekarza(
		vId NUMBER
	)IS
		vCzyIstnieje NUMBER;
		BEGIN
		
			select count(*) into vCzyIstnieje
			from Lekarze
			where id_lekarza = vId;
		
			delete from Lekarze where id_lekarza = vId;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBledneIdLekarz;
	END UsunLekarza;

	PROCEDURE UsunPielegniarke(
		vId NUMBER
	)IS
		vCzyIstnieje NUMBER;
		BEGIN
		
			select count(*) into vCzyIstnieje
			from Pielegniarki
			where id_pielegniarki = vId;
			
			delete from Pielegniarki where id_pielegniarki = vId;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBledneIdPielegniarka;
	END UsunPielegniarke;

	PROCEDURE PrzypiszSpecjalizacje(
		vNazwisko VARCHAR, 
		vSpecjalizacja VARCHAR
	)IS
		vIloscSpec NUMBER;
		vCzyPosiada NUMBER;
		BEGIN
		
			SELECT count(*) into vIloscSpec 
			from Specjalizacje 
			where nazwa = vSpecjalizacja;
		
			if vIloscSpec = 0 then
				RAISE exBlednaSpecjalizacja;
			end if;
			
			select count(*) into vCzyPosiada
			from Lekarze
			where specjalizacja = vSpecjalizacja;
			
			if vCzyPosiada = 1 then
				RAISE exPosiadaJuzSpecjalizacje;
			end if;
		
			UPDATE Lekarze
			SET specjalizacja = vSpecjalizacja
			WHERE nazwisko like vNazwisko;
	END PrzypiszSpecjalizacje;

	PROCEDURE DodajSpecjalizacje(
		vNazwa VARCHAR
	)IS
		vCzyIstnieje NUMBER;
		BEGIN
		
			select count(*) into vCzyIstnieje
			from Specjalizacje
			where nazwa = vNazwa;
			
			if vCzyIstnieje = 1 then
				RAISE exIstniejeSpecjalizacja;
			end if;
		
			insert into Specjalizacje
			values(vNazwa);
	END DodajSpecjalizacje;

	PROCEDURE UsunSpecjalizacje(
		vNazwa VARCHAR
	)IS
		vCzyIstnieje NUMBER;
		BEGIN
		
			select count(*) into vCzyIstnieje
			from Specjalizacje
			where nazwa = vNazwa;
			
			delete from Specjalizacje
			where nazwa = vNazwa;
			
			EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBrakSpecjalizacji;
	END UsunSpecjalizacje;

	FUNCTION OddzialLekarzId(
		vId NUMBER
	)RETURN VARCHAR IS
		vWynik VARCHAR(50);
			BEGIN
				select oddzial
				into vWynik
				from Lekarze
				where id_lekarza like vId;
				RETURN vWynik;
				
		EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBledneIdLekarz;		
	END OddzialLekarzId;

	FUNCTION OddzialPielegniarkaId(
		vId NUMBER
	)RETURN VARCHAR IS
		vWynik VARCHAR(50);
			BEGIN
				select oddzial
				into vWynik
				from Pielegniarki
				where id_pielegniarki like vId;
				RETURN vWynik;
		
		EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBledneIdPielegniarka;		
	END OddzialPielegniarkaId;

	FUNCTION NazwiskoLekarz(
		vId NUMBER
	)RETURN VARCHAR IS
		vWynik VARCHAR(100);
		BEGIN
			select nazwisko
			into vWynik
			from Lekarze
			where id_lekarza like vId;
			RETURN vWynik;
		EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBledneIdLekarz;		
		
	END NazwiskoLekarz;

	FUNCTION NazwiskoPielegniarka(
		vId NUMBER
	)RETURN VARCHAR IS
		vWynik VARCHAR(100);
		BEGIN
			select nazwisko
			into vWynik
			from Pielegniarki
			where id_pielegniarki like vId;
			RETURN vWynik;
		
		EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBledneIdPielegniarka;	
	END NazwiskoPielegniarka;
END PracownicySzpitala;

--zarzadzanie sprzetem
CREATE OR REPLACE PACKAGE SerwisSprzetu
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
	exBlednyOddzial EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBlednyOddzial, -20001);
	
	exBlednyNrSeryjny EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBlednyNrSeryjny, -20008);

	exNrSeryjnyIstnieje EXCEPTION;
	PRAGMA EXCEPTION_INIT(exNrSeryjnyIstnieje, -20009);
	
END SerwisSprzetu;

CREATE OR REPLACE PACKAGE BODY SerwisSprzetu IS
	PROCEDURE DodajSprzet(
		vNrSeryjny VARCHAR, 
		nazwa VARCHAR, 
		producent VARCHAR, 
		rok_produkcji DATE, 
		vOddzial VARCHAR
	)IS
		vIloscOdd NUMBER;
		vCzyIstnieje NUMBER;
		BEGIN
			SELECT count(*) into vIloscOdd 
			from oddzialy 
			where nazwa = vOddzial;
			
			if vIloscOdd = 0 then
				RAISE exBlednyOddzial;
			end if;
			
			SELECT count(*) into vCzyIstnieje 
			from Sprzety 
			where numer_seryjny = vNrSeryjny;
			
			if vIloscOdd = 1 then
				RAISE exNrSeryjnyIstnieje;
			end if;

			insert into Sprzety
			values(vNrSeryjny, nazwa, producent, rok_produkcji, vOddzial);
	END DodajSprzet;

	PROCEDURE UsunSprzet(
		vNrSeryjny VARCHAR
	)IS
		vCzyIstnieje NUMBER;	
		BEGIN
			
			select count(*) into vCzyIstnieje
			from Sprzety
			where numer_seryjny = vNrSeryjny;
		
			delete from Sprzety where numer_seryjny = vNrSeryjny;
			
		EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBlednyNrSeryjny;
	END UsunSprzet;

	PROCEDURE PrzeniesSprzet(
		vNrSeryjny VARCHAR, 
		vOddzial VARCHAR
	)IS
		vIloscOdd NUMBER;
		vCzyIstnieje NUMBER;
		BEGIN
		
			SELECT count(*) into vIloscOdd 
			from oddzialy 
			where nazwa = vOddzial;
			
			if vIloscOdd = 0 then
				RAISE exBlednyOddzial;
			end if;
			
			SELECT count(*) into vCzyIstnieje 
			from Sprzety 
			where numer_seryjny = vNrSeryjny;
			
			if vCzyIstnieje = 0 then
				RAISE exBlednyNrSeryjny;
			end if;
		
			UPDATE Sprzety
			SET nazwa_oddzialu = vOddzial
			WHERE numer_seryjny like vNrSeryjny;
	END PrzeniesSprzet;

	FUNCTION OddzialSprzet(
		vNrSeryjny VARCHAR
	)RETURN VARCHAR IS
		vWynik VARCHAR(50);
		BEGIN
			select nazwa_oddzialu
			into vWynik
			from Sprzety
			where numer_seryjny like vNrSeryjny;
			RETURN vWynik;
			
		EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBlednyNrSeryjny;	
	END OddzialSprzet;

	FUNCTION NazwaSprzet(
		vNrSeryjny VARCHAR
	)RETURN VARCHAR IS
		vWynik VARCHAR(50);
		BEGIN
			select nazwa
			into vWynik
			from Sprzety
			where numer_seryjny like vNrSeryjny;
			RETURN vWynik;
			
			EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBlednyNrSeryjny;	
	END NazwaSprzet;
END SerwisSprzetu;

--zarzadzanie oddzialami i salami
CREATE OR REPLACE PACKAGE OddzialySale
  IS
    PROCEDURE DodajOddzial(
		vNazwa VARCHAR, 
		vOpis VARCHAR default NULL);
		
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
	
	exBlednyOddzial EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBlednyOddzial, -20001);
	
	exBlednaSala EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBlednaSala, -20010);
	
END OddzialySale;

CREATE OR REPLACE PACKAGE BODY OddzialySale IS
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
			vIloscOdd NUMBER;
			
			BEGIN
				SELECT count(*) into vIloscOdd 
			from oddzialy 
			where nazwa = vOddzial;
			
			if vIloscOdd = 0 then
				RAISE exBlednyOddzial;
			end if;
			
				insert into Sale
				values(vNumer, vPietro, vOddzial);
	END DodajSale;

	PROCEDURE ZamknijOddzial(
		vNazwa VARCHAR
	)IS
		vIloscOdd NUMBER;
			
			BEGIN
			SELECT count(*) into vIloscOdd 
			from oddzialy 
			where nazwa = vNazwa;
			
			if vIloscOdd = 0 then
				RAISE exBlednyOddzial;
			end if;
			delete from Oddzialy where nazwa = vNazwa;
	END ZamknijOddzial;

	PROCEDURE ZamknijSale(
		vNumer NUMBER
	)IS
		vIloscSal NUMBER;
			
			BEGIN
				SELECT count(*) into vIloscSal 
			from sale 
			where numer = vNumer;
			
			if vIloscSal = 0 then
				RAISE exBlednaSala;
			end if;
			delete from Sale where numer = vNumer;
	END ZamknijSale;

	FUNCTION PietroSali(
		vNumer NUMBER
	)RETURN NUMERIC IS
		vWynik NUMBER;
		BEGIN
			select pietro
			into vWynik
			from Sale
			where numer like vNumer;
			RETURN vWynik;
			
		EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBlednaSala;	
	END PietroSali;

	FUNCTION OpisOddzialu(
		vNazwa VARCHAR
	)RETURN VARCHAR IS
		vWynik VARCHAR(50);
		BEGIN
			select opis
			into vWynik
			from Oddzialy
			where nazwa like vNazwa;
			RETURN vWynik;
			
		EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBlednyOddzial;	
	END OpisOddzialu;
END OddzialySale;

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
	
	exBledneIdLekarz EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBledneIdLekarz, -20003);
	
	exBlednaSala EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBlednaSala, -20010);
	
	exBrakPacjenta EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBrakPacjenta, -20011);
	
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
		vCzyIstnieje NUMBER;
		vIloscSal NUMBER;
		BEGIN
			
			select count(*) into vCzyIstnieje
			from Lekarze
			where id_lekarza = vLekarz;
			
			IF vCzyIstnieje = 0 then
				RAISE exBledneIdLekarz;
			end if;
			
			select count(*) into vIloscSal
			from Sale
			where numer = vSala;
			
			IF vIloscSal = 0 then
				RAISE exBlednaSala;
			end if;
		
			insert into Pacjenci
			values(vImie, vNazwisko, vDataUr, vPesel, vUlica, vMiasto, vKodPoczt, vTelefon);
			insert into Przyjecia
			values(current_timestamp, vLekarz, vPesel, vSala);
	END PrzyjeciePacjenta;

	PROCEDURE WypiszPacjenta(
		vPesel VARCHAR
	)IS
		vCzyPacjent NUMBER;
		BEGIN
		
		select count(*) into vCzyPacjent
			from Pacjenci
			where pesel = vPesel;
			
			IF vCzyPacjent = 0 then
				RAISE exBrakPacjenta;
			end if;
		
		
			delete from Przyjecia where pacjent = vPesel;
			delete from Pacjenci where pesel = vPesel;
	END WypiszPacjenta;

	PROCEDURE ZmienSale(
		vPesel VARCHAR, 
		vSala NUMBER
	)IS
		vIloscSal NUMBER;
		vCzyPacjent NUMBER;
		BEGIN
		
		select count(*) into vCzyPacjent
			from Pacjenci
			where pesel = vPesel;
			
			IF vCzyPacjent = 0 then
				RAISE exBrakPacjenta;
			end if;
		
		select count(*) into vIloscSal
			from Sale
			where numer = vSala;
			
			IF vIloscSal = 0 then
				RAISE exBlednaSala;
			end if;
		
		
			UPDATE Przyjecia
			SET nr_sali = vSala
			WHERE pacjent like vPesel;
	END ZmienSale;
	
	FUNCTION SprawdzOddzial(
		vPesel VARCHAR
	)RETURN VARCHAR IS
		vWynik VARCHAR(50);
		vSala NUMBER;
		
		vCzyPacjent NUMBER;
		BEGIN
		
			select count(*) into vCzyPacjent
			from Pacjenci
			where pesel = vPesel;
			
			IF vCzyPacjent = 0 then
				RAISE exBrakPacjenta;
			end if;
		
			select nr_sali
			into vSala
			from Przyjecia
			where pacjent like vPesel;
			
			select oddzial
			into vWynik
			from Sale
			where numer = vSala;
			RETURN vWynik;
	END SprawdzOddzial;

	FUNCTION SprawdzSale(
		vPesel VARCHAR
	)RETURN NUMERIC IS
		vWynik NUMBER;
		BEGIN
			select nr_sali
			into vWynik
			from Przyjecia
			where pacjent like vPesel;
			RETURN vWynik;
			
		EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBrakPacjenta;	
	END SprawdzSale;

	FUNCTION LekarzProwadzacy(
		vPesel VARCHAR
	)RETURN NUMERIC IS
		vWynik NUMBER;
		BEGIN
			select lekarz
			into vWynik
			from Przyjecia
			where pacjent like vPesel;
			RETURN vWynik;
			
		EXCEPTION WHEN NO_DATA_FOUND THEN
				RAISE exBrakPacjenta;
	END LekarzProwadzacy;
END Chorzy;

--zarzadzanie Badaniami
CREATE OR REPLACE PACKAGE PrzeprowadzaneBadania
  IS
    PROCEDURE SkierujNaBadanie( 
		vPesel VARCHAR,
		vLekarz NUMBER, 
		vBadanie VARCHAR);
		
	PROCEDURE PodajWyniki( 
		vBadanie NUMBER,
		vWynik VARCHAR, 
		vZalecenia VARCHAR default 'BRAK');
		
		
	FUNCTION SprawdzWyniki(
		vBadanie NUMBER
	)RETURN VARCHAR;
	
	FUNCTION SprawdzZalecenia(
		vBadanie NUMBER
	)RETURN VARCHAR;
	
	FUNCTION SprawdzCeneBadania(
		vBadanie VARCHAR
	)RETURN NUMERIC;
	
	exBledneIdLekarz EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBledneIdLekarz, -20003);
	
	exBrakPacjenta EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBrakPacjenta, -20011);
	
	exBrakBadania EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBrakBadania, -20012);
	
	exBrakWykonanegoBadania EXCEPTION;
	PRAGMA EXCEPTION_INIT(exBrakWykonanegoBadania, -20013);
	
END PrzeprowadzaneBadania;

CREATE OR REPLACE PACKAGE BODY PrzeprowadzaneBadania IS
	PROCEDURE SkierujNaBadanie( 
		vPesel VARCHAR,
		vLekarz NUMBER, 
		vBadanie VARCHAR
	)IS
		vCzyPacjent NUMBER;
		vCzyLekarz NUMBER;
		vCzyBadanie NUMBER;
		vId NUMBER;
		BEGIN
			
			select count(*) into vCzyPacjent
			from Pacjenci
			where pesel = vPesel;
			
			IF vCzyPacjent = 0 then
				RAISE exBrakPacjenta;
			end if;
			
			select count(*) into vCzyLekarz
			from Lekarze
			where id_lekarza = vLekarz;
			
			IF vCzyLekarz = 0 then
				RAISE exBledneIdLekarz;
			end if;
			
			select count(*) into vCzyBadanie
			from Badania
			where nazwa = vBadanie;
			
			IF vCzyBadanie = 0 then
				RAISE exBrakBadania;
			end if;
			
			vId := badania_id.nextval;
			
			insert into BadaniaPacjentow
			values(vId, vBadanie, vPesel, vLekarz, current_timestamp);
			
	END SkierujNaBadanie;

	PROCEDURE PodajWyniki( 
		vBadanie NUMBER,
		vWynik VARCHAR, 
		vZalecenia VARCHAR default 'BRAK'
	)IS
		vCzyBadanie NUMBER;
		vId NUMBER;
		BEGIN
		
		select count(*) into vCzyBadanie
			from BadaniaPacjentow
			where id_badania = vBadanie;
			
			IF vCzyBadanie = 0 then
				RAISE exBrakWykonanegoBadania;
			end if;
		
			vId := wyniki_id.nextval;
		
			insert into Wyniki
			values(vId, vBadanie, vWynik, vZalecenia);
			
	END PodajWyniki;
	
	FUNCTION SprawdzWyniki(
		vBadanie NUMBER
	)RETURN VARCHAR IS
		vWynik VARCHAR(100);
		
		
		vCzyBadanie NUMBER;
		BEGIN
		
			select count(*) into vCzyBadanie
			from BadaniaPacjentow
			where id_badania = vBadanie;
			
			IF vCzyBadanie = 0 then
				RAISE exBrakWykonanegoBadania;
			end if;
			
			select wynik_badania
			into vWynik
			from Wyniki
			where id_badania = vBadanie;
			RETURN vWynik;
	END SprawdzWyniki;
	
	FUNCTION SprawdzZalecenia(
		vBadanie NUMBER
	)RETURN VARCHAR IS
		vWynik VARCHAR(100);
		
		
		vCzyBadanie NUMBER;
		BEGIN
		
			select count(*) into vCzyBadanie
			from BadaniaPacjentow
			where id_badania = vBadanie;
			
			IF vCzyBadanie = 0 then
				RAISE exBrakWykonanegoBadania;
			end if;
			
			select zalecenia
			into vWynik
			from Wyniki
			where id_badania = vBadanie;
			RETURN vWynik;
	END SprawdzZalecenia;
	
	FUNCTION SprawdzCeneBadania(
		vBadanie VARCHAR
	)RETURN NUMERIC IS
		vWynik NUMERIC;
		vCzyBadanie NUMBER;
		BEGIN
		
			select count(*) into vCzyBadanie
			from Badania
			where nazwa = vBadanie;
			
			IF vCzyBadanie = 0 then
				RAISE exBrakBadania;
			end if;
			
			select cena
			into vWynik
			from Badania
			where nazwa = vBadanie;
			RETURN vWynik;
	END SprawdzCeneBadania;

END PrzeprowadzaneBadania;