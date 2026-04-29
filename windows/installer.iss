#define MyAppVersion "1.0.0"
[Setup]
; AppId unik untuk aplikasi ini agar Windows bisa membedakan instalasinya
AppId={{B2F6D1F1-A821-4F41-A3C9-183FBE6348D6}
AppName=Operation Core
; AppVersion ini akan di-inject secara otomatis oleh GitHub Actions nantinya
AppVersion={#MyAppVersion}
AppPublisher=Operation Core Team
DefaultDirName={autopf}\Operation Core
DisableProgramGroupPage=yes
; Nama file output installer-nya nanti: OperationCore-Setup.exe
OutputBaseFilename=OperationCore-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; Mematikan peringatan untuk menimpa (overwrite) file yang lama agar update mulus
CloseApplications=force

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Mengambil file executable utama
Source: "..\build\windows\x64\runner\Release\operationcore2.exe"; DestDir: "{app}"; Flags: ignoreversion
; Mengambil sisa file pendukung (data, dll, file .bin)
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Catatan: "ignoreversion" memberitahu installer untuk langsung menimpa file lama tanpa banyak tanya

[Icons]
Name: "{autoprograms}\Operation Core"; Filename: "{app}\operationcore2.exe"
Name: "{autodesktop}\Operation Core"; Filename: "{app}\operationcore2.exe"; Tasks: desktopicon

[Run]
; Menjalankan aplikasi secara otomatis setelah selesai install, bahkan jika mode silent (/VERYSILENT)
Filename: "{app}\operationcore2.exe"; Description: "{cm:LaunchProgram,Operation Core}"; Flags: nowait postinstall
