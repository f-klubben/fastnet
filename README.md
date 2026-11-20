# Projekt Fastnet

Dokumentation af opsætningen af den fysiske fastnettelefon i Jægerstuen, både hardware og konfiguration af Asterisk (RasPBX).

## Overblik

Jægerstuens fastnettelefon <-> vilkårlig mobiltelefon:

```
[Gammel fastnettelefon] -- trebenet telefonstikprop
        |
        |   RJ11 (telefonstik -> fastnetstik-adapter)
        v
[RJ45]  -- fastnettelefon kobles til FXS-porten i ATA-modemmet
        |
        |   ATA-modemmet tages op til en netværksport i Raspberry Pi
        v
[Raspberry Pi (RasPBX installeret)]
        |
        |   anden netværksport -> internettet
        v
[RasPBX / Asterisk]
        |   - lokal telefon = extension i Asterisk
        |   - IVR-menu med indstilling "Ring til Jægerstuen" -> lokal extension
        |   - indkommende opkald -> viderestilles direkte til lokal extension
        |   - privat fastnet-udbyder (fx viptel.dk) = primær SIP-trunk
        v
[viptel.dk el. lign.]
        |   - modtager opkald fra Asterisk -> viderestiller til Danmarks mobilnet
        |   - modtager opkald fra mobilnettet -> sendes til Asterisk
        v
[Mobiltelefon] -- ringer op / bliver ringet op
```

---

## Hardware

Den fysiske sammensætning af komponenter fra fastnettelefon til internettet og anvendt udstyr.

### Sammensætning

1. Gammel fastnettelefon
   - Trebenet telefonstikprop (telefonstik der normalt sættes direkte i væggen)
2. Telefonstik -> fastnetkabel (-> RJ11)
   - Ekstra fysisk stikprop der oversætter telefonstik til fastnetkabel (til RJ11-forbindelsen mellem telefon og adapter)
3. Fastnettelefon -> ATA-modem (-> RJ45)
   - Telefonen kobles til FXS-porten i ATA-modemmet
4. ATA-modem -> Raspberry Pi
   - ATA-modemmet kobles til en netværksport på Raspberry Pi.
5. Raspberry Pi -> internettet
   - Anden netværksport på Raspberry Pi går til internettet.
   - Kører RasPBX (Asterisk).

### Anvendt udstyr

| Enhed | Model / note |
|---|---|
| Fastnettelefon | Vilkårlig fastnettelefon med enten RJ11 eller telefonstik kabling |
| Telefonstik-adapter | Skal kun bruges hvis fastnettelefonen ikke har RJ11 stik fra start |
| ATA-modem | Behøves kun hvis man bruger fastnettelefon fremfor en IP-telefon |
| Raspberry Pi 3/4/5 | (RasPBX-installeret) |

---

## Asterisk (RasPBX)

Konfiguration af extensions, IVR, indgående routing og SIP-trunk

### Extension

- Den lokale fastnettelefon konfigureres som en extension i Asterisk
- Extensionnummer: ___ / SIP-credentials for extensionen: ___

### IVR-menu

- IVR-menu med indstillingen "Ring til Jægerstuen"
- Valget forbindes til den lokale extension, telefonen sidder på

### Indgående opkald

- Indkommende opkald viderestilles direkte til den lokale extension med telefonen på

### SIP-trunk / fastnet-udbyder

- Privat fastnetudbyder (fx viptel.dk) konfigureres som primær SIP-trunk
- Asterisk sender opkald til udbyderen, som viderestiller til Danmarks mobilnet. Opkald fra mobilnettet modtages af udbyderen og sendes til Asterisk.

Trunk-oplysninger (viptel.dk eller anden udbyder): username ___, password ___, server/host ___, registrering på/af ___.

---

## Arbejdsgang

1. Ret filerne i repoet
2. Commit og push
3. På Pi'en: `cd ~/fastnet && git pull && sudo ./sync.sh`
4. Genindlæs Asterisk: `./reload-dialplan.sh`

