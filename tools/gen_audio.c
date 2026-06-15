/*
 * gen_audio.c — Gerador de audio do Fruit Catcher (em C puro).
 *
 * Sintetiza os efeitos sonoros e a musica de fundo do jogo e grava
 * arquivos .wav (PCM 16-bit, mono, 44100 Hz) na pasta indicada.
 *
 * Uso:
 *     gen_audio.exe Assets/Audio/
 *
 * Nao depende de bibliotecas externas — apenas a biblioteca padrao do C.
 * Os arquivos gerados sao:
 *     som_coleta.wav     som_dourada.wav    som_congelante.wav
 *     som_podre.wav      som_gameover.wav   musica_fundo.wav
 */

#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>

#define SR 44100              /* taxa de amostragem (Hz) */
#define PI 3.14159265358979323846

/* ---------------------------------------------------------------------------
 * Grava um vetor de amostras (16-bit) em um arquivo .wav valido.
 * ------------------------------------------------------------------------- */
static void write_wav(const char *path, const short *samples, int n)
{
    FILE *f = fopen(path, "wb");
    if (!f) { printf("ERRO: nao consegui criar %s\n", path); return; }

    int32_t data_bytes = n * 2;          /* mono, 2 bytes por amostra */
    int32_t byte_rate  = SR * 2;
    int32_t chunk_size = 36 + data_bytes;
    int32_t subchunk1  = 16;
    int16_t audio_fmt  = 1;              /* PCM */
    int16_t channels   = 1;
    int32_t sample_rate = SR;
    int16_t block_align = 2;
    int16_t bits        = 16;

    /* Cabecalho RIFF/WAVE (x86 e little-endian, igual ao formato WAV). */
    fwrite("RIFF", 1, 4, f);
    fwrite(&chunk_size, 4, 1, f);
    fwrite("WAVE", 1, 4, f);
    fwrite("fmt ", 1, 4, f);
    fwrite(&subchunk1, 4, 1, f);
    fwrite(&audio_fmt, 2, 1, f);
    fwrite(&channels, 2, 1, f);
    fwrite(&sample_rate, 4, 1, f);
    fwrite(&byte_rate, 4, 1, f);
    fwrite(&block_align, 2, 1, f);
    fwrite(&bits, 2, 1, f);
    fwrite("data", 1, 4, f);
    fwrite(&data_bytes, 4, 1, f);
    fwrite(samples, 2, n, f);
    fclose(f);
}

/* Oscilador: wave = 0 -> senoide (suave); wave = 1 -> onda quadrada (chiptune). */
static double osc(double phase, int wave)
{
    double s = sin(phase);
    if (wave == 1) return (s >= 0.0) ? 1.0 : -1.0;
    return s;
}

/*
 * Soma uma nota (tom) no buffer, com envelope simples (ataque/decaimento)
 * para evitar "clicks" no inicio e no fim do som.
 */
static void add_tone(float *buf, int total, double start_s, double dur_s,
                     double freq, double amp, int wave)
{
    int start = (int)(start_s * SR);
    int len   = (int)(dur_s * SR);
    double attack  = 0.005 * SR;   /* ~5 ms subindo  */
    double release = 0.015 * SR;   /* ~15 ms descendo */

    for (int i = 0; i < len; i++) {
        int idx = start + i;
        if (idx < 0 || idx >= total) continue;

        double env = 1.0;
        if (i < attack)              env = i / attack;
        else if (i > len - release)  env = (len - i) / release;
        if (env < 0.0) env = 0.0;

        double phase = 2.0 * PI * freq * (double)i / (double)SR;
        buf[idx] += (float)(amp * env * osc(phase, wave));
    }
}

/* Aloca um buffer de 'sec' segundos zerado. */
static float *new_buf(double sec, int *n)
{
    *n = (int)(sec * SR) + 1;
    return (float *)calloc((size_t)(*n), sizeof(float));
}

/* Normaliza (clamp), converte para 16-bit e grava. */
static void render(const char *path, float *buf, int n)
{
    short *out = (short *)malloc(sizeof(short) * (size_t)n);
    for (int i = 0; i < n; i++) {
        double v = buf[i];
        if (v >  1.0) v =  1.0;
        if (v < -1.0) v = -1.0;
        out[i] = (short)(v * 32000.0);
    }
    write_wav(path, out, n);
    free(out);
    printf("  gerado: %s\n", path);
}

int main(int argc, char **argv)
{
    const char *dir = (argc > 1) ? argv[1] : "Assets/Audio/";
    char path[512];
    int n;
    float *b;

    printf("Gerando audio do Fruit Catcher...\n");

    /* === SOM DE COLETA: dois blips ascendentes (alegre) === */
    b = new_buf(0.16, &n);
    add_tone(b, n, 0.00, 0.06, 880.00, 0.50, 0);    /* A5 */
    add_tone(b, n, 0.05, 0.09, 1318.51, 0.50, 0);   /* E6 */
    sprintf(path, "%ssom_coleta.wav", dir); render(path, b, n); free(b);

    /* === FRUTA DOURADA: arpejo brilhante C-E-G-C + brilho === */
    b = new_buf(0.40, &n);
    double arp[4] = { 523.25, 659.25, 783.99, 1046.50 };
    for (int i = 0; i < 4; i++)
        add_tone(b, n, i * 0.07, 0.11, arp[i], 0.42, 0);
    add_tone(b, n, 0.28, 0.11, 1567.98, 0.25, 0);   /* G6 sparkle */
    sprintf(path, "%ssom_dourada.wav", dir); render(path, b, n); free(b);

    /* === FRUTA CONGELANTE: cintilar gelado descendente === */
    b = new_buf(0.42, &n);
    double ice[4] = { 2349.32, 1975.53, 1567.98, 1318.51 };
    for (int i = 0; i < 4; i++)
        add_tone(b, n, i * 0.06, 0.15, ice[i], 0.30, 0);
    add_tone(b, n, 0.00, 0.40, 3135.96, 0.10, 0);   /* brilho agudo */
    sprintf(path, "%ssom_congelante.wav", dir); render(path, b, n); free(b);

    /* === FRUTA PODRE: zumbido grave dissonante (erro) === */
    b = new_buf(0.32, &n);
    add_tone(b, n, 0.00, 0.26, 130.81, 0.40, 1);
    add_tone(b, n, 0.00, 0.26, 138.59, 0.34, 1);    /* batimento dissonante */
    add_tone(b, n, 0.13, 0.16, 98.00, 0.30, 1);     /* cai mais grave */
    sprintf(path, "%ssom_podre.wav", dir); render(path, b, n); free(b);

    /* === GAME OVER: sequencia descendente (triste) === */
    b = new_buf(0.95, &n);
    double go[4] = { 392.00, 329.63, 261.63, 196.00 };
    for (int i = 0; i < 4; i++)
        add_tone(b, n, i * 0.20, 0.24, go[i], 0.40, 1);
    sprintf(path, "%ssom_gameover.wav", dir); render(path, b, n); free(b);

    /* === MUSICA DE FUNDO: loop chiptune de 4 compassos (melodia + baixo) === */
    double bpm = 130.0;
    double eighth  = (60.0 / bpm) / 2.0;   /* colcheia */
    double quarter = 60.0 / bpm;           /* seminima */
    double total   = quarter * 4.0 * 4.0;  /* 4 compassos em 4/4 */
    b = new_buf(total, &n);

    /* Melodia (32 colcheias): C - G - Am - F */
    double mel[32] = {
        523.25, 659.25, 783.99, 659.25,  523.25, 659.25, 783.99, 659.25,
        587.33, 783.99, 987.77, 783.99,  587.33, 783.99, 987.77, 783.99,
        440.00, 523.25, 659.25, 523.25,  440.00, 523.25, 659.25, 523.25,
        349.23, 440.00, 523.25, 440.00,  349.23, 440.00, 523.25, 440.00
    };
    for (int i = 0; i < 32; i++)
        add_tone(b, n, i * eighth, eighth * 0.92, mel[i], 0.20, 1);

    /* Linha de baixo (16 seminimas): raiz e quinta de cada acorde */
    double bass[16] = {
        130.81, 196.00, 130.81, 196.00,   /* C  */
        196.00, 293.66, 196.00, 293.66,   /* G  */
        220.00, 329.63, 220.00, 329.63,   /* Am */
        174.61, 261.63, 174.61, 261.63    /* F  */
    };
    for (int i = 0; i < 16; i++)
        add_tone(b, n, i * quarter, quarter * 0.92, bass[i], 0.17, 1);

    sprintf(path, "%smusica_fundo.wav", dir); render(path, b, n); free(b);

    printf("Pronto! Arquivos .wav criados em \"%s\".\n", dir);
    return 0;
}
