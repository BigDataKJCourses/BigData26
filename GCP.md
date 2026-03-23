# Utworzenie maszyny wirtualnej na GCP

1. Otwórz konsolę platformy GCP https://console.cloud.google.com/ 

2. Otwórz *Cloud Shell*

3. Przeanalizuj a następnie uruchom poniższe polecenie tworzące naszą maszynę, którą następnie przygotujemy na potrzeby środowiska *BigData26*

```sh
gcloud compute instances create instance-20260312-173600 \
    --project=bigdata-course-lectures-187012 \
    --zone=europe-west4-a \
    --machine-type=e2-standard-8 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=1029715848953-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --tags=docker-server \
    --create-disk=boot=yes,device-name=instance-20260312-173600,image=projects/debian-cloud/global/images/debian-12-bookworm-v20260310,mode=rw,size=100,type=pd-ssd \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any
```

4. Przejdź do interfejsu usługi *Compute Engine*, do listy przedstawiającej wirtualne maszyny: *Compute Engine*->*VM Instances*

5. Otwórz terminal SSH, logując się do wnętrza tej maszyny


# Jednorazowa konfiguracja maszyny

1. Przygotowanie systemu

Najpierw zaktualizujemy listę pakietów i zainstalujemy narzędzia potrzebne do pobrania kluczy GPG:

```sh
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
```

2. Dodanie oficjalnego klucza i repozytorium Docker
Musimy powiedzieć Debianowi, skąd ma brać bezpieczne paczki Dockera:

```sh
# Dodanie klucza GPG
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Dodanie repozytorium do źródeł APT
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
```

3. Instalacja Dockera i Docker Compose
Teraz instalujemy sam silnik oraz wtyczkę Compose (która na pewno Ci się przyda przy "złożonej konfiguracji"):

```sh
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

4. Konfiguracja uprawnień (Kluczowe!)
Abyś nie musiał wpisywać sudo przed każdą komendą docker, dodaj swojego użytkownika do grupy docker:

```sh
sudo usermod -aG docker $USER

newgrp docker
```

Jak sprawdzić, czy wszystko działa?
Wpisz prostą komendę:

```sh
docker compose version
docker run hello-world
```

# Instalacja naszego środowiska 

Postępujemy zgodnie z 
https://github.com/BigDataKJCourses/BigData26

> Uwaga! Przed uruchomieniem tworzenia obrazów, które mogą bardzo długo trwać, warto zainstalować narzędzie 'screen`

```sh
sudo apt install screen -y

screen # przed build.sh

screen -r # powrót do sesji pobierania w razie gdyby w miedzyczasie sesja SSH została rozłączona 
```

# Dostęp do interfejsów 

1. Dostęp do terminala SSH - j.w.

2. Dostęp do interfejsów sieciowych. 

  - wariant A (`PuTTy`)

    - Konfigurujemy PuTTy 
    - Definiujemy tunele  

  - wariant B (*Remote - SSH* w VSC)

    - narzędzie `gcloud` 
    - wtyczkę do VSC `Remote - SSH` Microsoftu 
    - trywialny dostęp do zawartości MV
      - `gcloud compute config-ssh`
      - dolny lewy róg `><` i połączenie z nowym serwerem  
    - trywialny sposób definiowania kolejnych tuneli jeśli będą potrzebne <br>
    Użyj Palety Komend
      - Naciśnij F1 (lub Ctrl + Shift + P).
      - Wpisz: Ports: Focus on Ports View.
      - Naciśnij Enter. VS Code natychmiast przeniesie Cię do tej zakładki.


# Zatrzymywanie maszyny

1. w Konsoli z dostępem do VM wyłaczamy 'Stop`

- Nie mamy stałych IP, więc za nie nie płacimy 
- Płacimy 100GB za obraz dysku - kilka centów dziennie 

2. Jeśli nie chcemy płacić za 100GB na dysku SSD, wówczas należy 
- utworzyć snapshot dysku 
- usunąć maszynę 

> Ma to sens jedynie, kiedy nie zamierzamy korzystać z tej maszyny przez miesiąc lub dłużej

# Koszty

- Przed powyższą procedurą pozostałe środki: **53,51$**. 
- Po zakończeniu konfiguracji pozostało: **52,88$**. 
- Po kolejnym dniu pozostało **52,22$** (koszt zatrzymanej maszyny i snapshota)
- Po jeszcze jednym (koszt dysku i snapshota) **51,53$**
* Mając utworzony snapshot można skasować dysk

# Dodatek 

Wirtualna Maszyna na GCP może zawierać całość środowiska BigData26, a nie tylko jego *dockerowe serce*. 

W tym celu należy zainstalować na niej usługi pozwalające podłączyć się za pomocą RDP (*Remote Desktop*) 

1. Instalacja lekkiego środowiska graficznego (XFCE)

Zamiast ciężkiego GNOME, zainstalujemy XFCE. Jest szybkie, stabilne i idealne do pracy zdalnej.

Połącz się przez SSH i wpisz:

```sh
sudo apt update
sudo apt install xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils -y
```

2. Instalacja i konfiguracja serwera XRDP

XRDP to usługa, która pozwoli Ci połączyć się z Linuxem za pomocą windowsowego "Podłączania pulpitu zdalnego".

```sh
sudo apt install xrdp -y

# Dodaj użytkownika xrdp do grupy ssl-cert (rozwiązuje problemy z uprawnieniami)
sudo adduser xrdp ssl-cert

# Uruchom i włącz usługę
sudo systemctl enable xrdp
sudo systemctl start xrdp
```

3. Ustawienie hasła dla Twojego użytkownika

Konta na GCP tworzone przez gcloud zazwyczaj logują się przez klucze SSH i nie mają ustawionego hasła. RDP wymaga tradycyjnego hasła.

Wpisz (zastąp `kjankiewicz` swoją nazwą użytkownika):

```sh
sudo passwd kjankiewicz
```

4. Łączymy się przez Putty i tworzmy tunel

Łączymy się przez PuTTY i ustawiamy tunel 3390 -> localhost:3389

W sesji PuTTY
```sh
# Utworzenie pliku konfiguracyjnego sesji dla Twojego użytkownika
echo "xfce4-session" > ~/.xsession

# Nadanie uprawnień do wykonywania (opcjonalnie, ale warto)
chmod +x ~/.xsession

# Restart usługi 
sudo systemctl restart xrdp
```

5. Łączymy się przez RDP

Warto zainstalować oprogramowanie, z którego będziemy korzystali 
- IntelliJ IDEA (for Java/Scala development)
- PyCharm (for Python/Spark scripts)
- DBeaver (for MySQL and ksqlDB data exploration)