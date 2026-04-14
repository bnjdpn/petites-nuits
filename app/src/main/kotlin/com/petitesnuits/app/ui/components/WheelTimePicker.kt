package com.petitesnuits.app.ui.components

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.gestures.snapping.rememberSnapFlingBehavior
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.CompositingStrategy
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.petitesnuits.app.ui.theme.Lavender
import com.petitesnuits.app.ui.theme.StarGold

private const val VISIBLE_ITEMS = 5
private val ITEM_HEIGHT = 48.dp

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun WheelTimePicker(
    selectedHour: Int,
    selectedMinute: Int,
    onTimeChanged: (hour: Int, minute: Int) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        WheelColumn(
            items = (0..23).toList(),
            selectedItem = selectedHour,
            onItemSelected = { onTimeChanged(it, selectedMinute) },
            format = { it.toString().padStart(2, '0') }
        )

        Text(
            ":",
            fontSize = 32.sp,
            fontWeight = FontWeight.Bold,
            color = StarGold,
            modifier = Modifier.width(24.dp),
            textAlign = TextAlign.Center
        )

        WheelColumn(
            items = (0..59).toList(),
            selectedItem = selectedMinute,
            onItemSelected = { onTimeChanged(selectedHour, it) },
            format = { it.toString().padStart(2, '0') }
        )
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun WheelColumn(
    items: List<Int>,
    selectedItem: Int,
    onItemSelected: (Int) -> Unit,
    format: (Int) -> String
) {
    val listState = rememberLazyListState()
    val snapBehavior = rememberSnapFlingBehavior(lazyListState = listState)

    val centerIndex by remember {
        derivedStateOf {
            val layoutInfo = listState.layoutInfo
            val viewportCenter = layoutInfo.viewportStartOffset +
                (layoutInfo.viewportEndOffset - layoutInfo.viewportStartOffset) / 2
            layoutInfo.visibleItemsInfo.minByOrNull {
                kotlin.math.abs((it.offset + it.size / 2) - viewportCenter)
            }?.index ?: 0
        }
    }

    LaunchedEffect(centerIndex) {
        val actualIndex = centerIndex % items.size
        if (items[actualIndex] != selectedItem) {
            onItemSelected(items[actualIndex])
        }
    }

    LaunchedEffect(selectedItem) {
        val currentCenterItem = items[centerIndex % items.size]
        if (currentCenterItem != selectedItem) {
            val targetIndex = items.indexOf(selectedItem)
            if (targetIndex >= 0) {
                val largeMiddle = (Int.MAX_VALUE / 2 / items.size) * items.size + targetIndex
                listState.scrollToItem(largeMiddle, scrollOffset = 0)
            }
        }
    }

    val totalHeight = ITEM_HEIGHT * VISIBLE_ITEMS

    Box(
        modifier = Modifier
            .height(totalHeight)
            .width(72.dp)
            .graphicsLayer(compositingStrategy = CompositingStrategy.Offscreen)
            .drawWithContent {
                drawContent()
                val fadeHeight = ITEM_HEIGHT.toPx() * 1.5f
                drawRect(
                    brush = Brush.verticalGradient(
                        0f to Color.Transparent,
                        fadeHeight / size.height to Color.Black,
                        1f - fadeHeight / size.height to Color.Black,
                        1f to Color.Transparent
                    ),
                    blendMode = BlendMode.DstIn
                )
            }
    ) {
        LazyColumn(
            state = listState,
            flingBehavior = snapBehavior,
            modifier = Modifier.height(totalHeight)
        ) {
            items(Int.MAX_VALUE) { index ->
                val actualIndex = index % items.size
                val value = items[actualIndex]
                val isSelected = actualIndex == (centerIndex % items.size)

                Box(
                    modifier = Modifier
                        .height(ITEM_HEIGHT)
                        .fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = format(value),
                        fontSize = if (isSelected) 28.sp else 18.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                        color = if (isSelected) StarGold else Lavender.copy(alpha = 0.5f),
                        textAlign = TextAlign.Center
                    )
                }
            }
        }

        // Center highlight bar
        Box(
            modifier = Modifier
                .align(Alignment.Center)
                .fillMaxWidth()
                .height(ITEM_HEIGHT)
                .drawWithContent {
                    drawContent()
                    drawLine(
                        Lavender.copy(alpha = 0.3f),
                        start = androidx.compose.ui.geometry.Offset(0f, 0f),
                        end = androidx.compose.ui.geometry.Offset(size.width, 0f),
                        strokeWidth = 1.dp.toPx()
                    )
                    drawLine(
                        Lavender.copy(alpha = 0.3f),
                        start = androidx.compose.ui.geometry.Offset(0f, size.height),
                        end = androidx.compose.ui.geometry.Offset(size.width, size.height),
                        strokeWidth = 1.dp.toPx()
                    )
                }
        )
    }
}
