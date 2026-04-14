package com.petitesnuits.app.ui.chart

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.petitesnuits.app.ui.theme.Lavender
import com.petitesnuits.app.ui.theme.StarGold
import com.petitesnuits.app.ui.theme.TextSecondary
import com.petitesnuits.app.ui.theme.WarmCoral
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun ChartScreen(viewModel: ChartViewModel) {
    val nights by viewModel.last14Nights.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            "Évolution des 14 dernières nuits",
            style = MaterialTheme.typography.titleLarge,
            color = StarGold
        )

        Spacer(modifier = Modifier.height(8.dp))

        if (nights.isEmpty()) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("🌙", fontSize = 48.sp)
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        "Aucune nuit enregistrée",
                        style = MaterialTheme.typography.bodyLarge,
                        color = TextSecondary
                    )
                }
            }
        } else {
            // Legend
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center
            ) {
                LegendItem(color = StarGold, label = "Sommeil (h)")
                Spacer(modifier = Modifier.size(24.dp))
                LegendItem(color = WarmCoral, label = "Réveils")
                Spacer(modifier = Modifier.size(24.dp))
                LegendItem(color = Lavender, label = "Effectif (h)")
            }

            Spacer(modifier = Modifier.height(16.dp))

            val sortedNights = nights.sortedBy { it.bedtime }
            val textMeasurer = rememberTextMeasurer()
            val dateFormat = SimpleDateFormat("dd/MM", Locale.FRENCH)
            val labelColor = TextSecondary
            val gridColor = Lavender.copy(alpha = 0.2f)

            Canvas(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(280.dp)
            ) {
                val leftPadding = 40.dp.toPx()
                val bottomPadding = 40.dp.toPx()
                val topPadding = 16.dp.toPx()
                val rightPadding = 16.dp.toPx()

                val chartWidth = size.width - leftPadding - rightPadding
                val chartHeight = size.height - topPadding - bottomPadding

                val maxHours = sortedNights.maxOf { it.sleepDurationMillis / 3_600_000f }.coerceAtLeast(1f) + 1f
                val maxWakeUps = sortedNights.maxOf { it.wakeUps.size }.coerceAtLeast(1) + 1

                // Grid lines
                for (i in 0..maxHours.toInt()) {
                    val y = topPadding + chartHeight - (i / maxHours * chartHeight)
                    drawLine(gridColor, Offset(leftPadding, y), Offset(size.width - rightPadding, y))
                    val result = textMeasurer.measure(
                        "${i}h",
                        style = androidx.compose.ui.text.TextStyle(fontSize = 10.sp, color = labelColor)
                    )
                    drawText(result, topLeft = Offset(0f, y - result.size.height / 2))
                }

                // Sleep line
                val sleepPath = Path()
                sortedNights.forEachIndexed { index, night ->
                    val x = leftPadding + (index.toFloat() / (sortedNights.size - 1).coerceAtLeast(1)) * chartWidth
                    val hours = night.sleepDurationMillis / 3_600_000f
                    val y = topPadding + chartHeight - (hours / maxHours * chartHeight)

                    if (index == 0) sleepPath.moveTo(x, y) else sleepPath.lineTo(x, y)
                    drawCircle(StarGold, 5.dp.toPx(), Offset(x, y))
                }
                drawPath(sleepPath, StarGold, style = Stroke(width = 3.dp.toPx(), cap = StrokeCap.Round))

                // Effective sleep line
                val effectivePath = Path()
                sortedNights.forEachIndexed { index, night ->
                    val x = leftPadding + (index.toFloat() / (sortedNights.size - 1).coerceAtLeast(1)) * chartWidth
                    val hours = night.effectiveSleepMillis / 3_600_000f
                    val y = topPadding + chartHeight - (hours / maxHours * chartHeight)

                    if (index == 0) effectivePath.moveTo(x, y) else effectivePath.lineTo(x, y)
                    drawCircle(Lavender, 4.dp.toPx(), Offset(x, y))
                }
                drawPath(effectivePath, Lavender, style = Stroke(width = 2.dp.toPx(), cap = StrokeCap.Round))

                // Wake-up bars
                sortedNights.forEachIndexed { index, night ->
                    val x = leftPadding + (index.toFloat() / (sortedNights.size - 1).coerceAtLeast(1)) * chartWidth
                    val barHeight = (night.wakeUps.size.toFloat() / maxWakeUps) * chartHeight
                    val barWidth = 8.dp.toPx()
                    drawRect(
                        WarmCoral.copy(alpha = 0.5f),
                        topLeft = Offset(x - barWidth / 2, topPadding + chartHeight - barHeight),
                        size = androidx.compose.ui.geometry.Size(barWidth, barHeight)
                    )
                }

                // Date labels
                sortedNights.forEachIndexed { index, night ->
                    if (index % (sortedNights.size / 5).coerceAtLeast(1) == 0 || index == sortedNights.size - 1) {
                        val x = leftPadding + (index.toFloat() / (sortedNights.size - 1).coerceAtLeast(1)) * chartWidth
                        val label = dateFormat.format(Date(night.bedtime))
                        val result = textMeasurer.measure(
                            label,
                            style = androidx.compose.ui.text.TextStyle(fontSize = 9.sp, color = labelColor)
                        )
                        drawText(result, topLeft = Offset(x - result.size.width / 2, size.height - bottomPadding + 8.dp.toPx()))
                    }
                }
            }
        }
    }
}

@Composable
private fun LegendItem(color: Color, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Canvas(modifier = Modifier.size(12.dp)) {
            drawCircle(color)
        }
        Spacer(modifier = Modifier.size(4.dp))
        Text(label, style = MaterialTheme.typography.bodySmall, color = TextSecondary)
    }
}
