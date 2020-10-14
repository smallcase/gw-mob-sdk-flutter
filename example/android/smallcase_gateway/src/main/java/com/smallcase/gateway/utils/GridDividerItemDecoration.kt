package com.smallcase.gateway.utils

import android.graphics.Canvas
import android.graphics.Rect
import android.graphics.drawable.Drawable
import android.util.Log
import android.view.View
import androidx.recyclerview.widget.RecyclerView


class GridDividerItemDecoration
/**
 * Sole constructor. Takes in [Drawable] objects to be used as
 * horizontal and vertical dividers.
 *
 * @param horizontalDivider A divider `Drawable` to be drawn on the
 * rows of the grid of the RecyclerView
 * @param verticalDivider A divider `Drawable` to be drawn on the
 * columns of the grid of the RecyclerView
 * @param numColumns The number of columns in the grid of the RecyclerView
 */(
    private val mHorizontalDivider: Drawable,
    private val mVerticalDivider: Drawable,
    private val mNumColumns: Int
) : RecyclerView.ItemDecoration() {

    override fun onDraw(c: Canvas, parent: RecyclerView, state: RecyclerView.State) {
        drawHorizontalDividers(c, parent)
        drawVerticalDividers(c, parent)
    }


    override fun getItemOffsets(
        outRect: Rect,
        view: View,
        parent: RecyclerView,
        state: RecyclerView.State
    ) {

        super.getItemOffsets(outRect, view, parent, state)
        val childIsInLeftmostColumn =
            parent.getChildAdapterPosition(view) % mNumColumns == 0
        if (!childIsInLeftmostColumn) {
            outRect.left = mHorizontalDivider.intrinsicWidth
        }
        val childIsInFirstRow: Boolean = parent.getChildAdapterPosition(view) < mNumColumns
        if (!childIsInFirstRow) {
            outRect.top = mVerticalDivider.intrinsicHeight
        }
        if (parent.getChildAdapterPosition(view)==parent.childCount-1)
        {
            outRect.set(outRect.left,outRect.top,outRect.right + mHorizontalDivider.intrinsicWidth,outRect.top)
        }
    }


    /**
     * Adds horizontal dividers to a RecyclerView with a GridLayoutManager or its
     * subclass.
     *
     * @param canvas The [Canvas] onto which dividers will be drawn
     * @param parent The RecyclerView onto which dividers are being added
     */
    private fun drawHorizontalDividers(canvas: Canvas, parent: RecyclerView) {
        val childCount: Int = parent.getChildCount()
        val rowCount = childCount / mNumColumns
        val lastRowChildCount = childCount % mNumColumns
        for (i in 1 until mNumColumns) {
            val lastRowChildIndex: Int = if (i < lastRowChildCount) {
                i + rowCount * mNumColumns
            } else {
                i + (rowCount - 1) * mNumColumns
            }

            if (parent.getChildAt(i)!=null && parent.getChildAt(lastRowChildIndex)!=null)
            {
                val firstRowChild: View = parent.getChildAt(i)
                val lastRowChild: View = parent.getChildAt(lastRowChildIndex)
                val dividerTop: Int = firstRowChild.top
                val dividerRight: Int = firstRowChild.left
                val dividerLeft = dividerRight - mHorizontalDivider.intrinsicWidth
                val dividerBottom: Int = lastRowChild.bottom + mVerticalDivider.intrinsicHeight
                mHorizontalDivider.setBounds(dividerLeft, dividerTop, dividerRight, dividerBottom)
                mHorizontalDivider.draw(canvas)
            }else
            {
                Log.e("mytag","i $i")
                Log.e("mytag","lastRowChildIndex $lastRowChildIndex")
            }

        }
        when
        {
            parent.getChildAt(3)!=null && parent.getChildAt(4)==null ->{
                mHorizontalDivider.setBounds(parent.getChildAt(3).right+mHorizontalDivider.intrinsicWidth, parent.getChildAt(3).top, parent.getChildAt(3).right + 2*mHorizontalDivider.intrinsicWidth, parent.getChildAt(3).bottom)
                mHorizontalDivider.draw(canvas)
            }
            parent.getChildAt(4)!=null && parent.getChildAt(5)==null ->{
                mHorizontalDivider.setBounds(parent.getChildAt(4).right+mHorizontalDivider.intrinsicWidth, parent.getChildAt(4).top, parent.getChildAt(4).right + 2*mHorizontalDivider.intrinsicWidth, parent.getChildAt(4).bottom)
                mHorizontalDivider.draw(canvas)
            }
            parent.getChildAt(6)!=null && parent.getChildAt(7)==null ->{
                mHorizontalDivider.setBounds(parent.getChildAt(6).right+mHorizontalDivider.intrinsicWidth, parent.getChildAt(6).top, parent.getChildAt(6).right + 2*mHorizontalDivider.intrinsicWidth, parent.getChildAt(6).bottom)
                mHorizontalDivider.draw(canvas)
            }
            parent.getChildAt(7)!=null && parent.getChildAt(8)==null ->{
                mHorizontalDivider.setBounds(parent.getChildAt(7).right+mHorizontalDivider.intrinsicWidth, parent.getChildAt(7).top, parent.getChildAt(7).right + 2*mHorizontalDivider.intrinsicWidth, parent.getChildAt(7).bottom)
                mHorizontalDivider.draw(canvas)
            }
        }
    }

    /**
     * Adds vertical dividers to a RecyclerView with a GridLayoutManager or its
     * subclass.
     *
     * @param canvas The [Canvas] onto which dividers will be drawn
     * @param parent The RecyclerView onto which dividers are being added
     */
    private fun drawVerticalDividers(
        canvas: Canvas,
        parent: RecyclerView
    ){
        val childCount = parent.childCount
        val rowCount = childCount / mNumColumns
        var rightmostChildIndex: Int
        for (i in 1..rowCount) {
            rightmostChildIndex = (i * mNumColumns) -1

            if (parent.getChildAt(i * mNumColumns)!=null && parent.getChildAt(rightmostChildIndex)!=null)
            {
                val leftmostChild = parent.getChildAt(i * mNumColumns)
                val rightmostChild = parent.getChildAt(rightmostChildIndex)
                val dividerLeft = leftmostChild.left
                val dividerBottom = leftmostChild.top
                val dividerTop = dividerBottom - mVerticalDivider.intrinsicHeight
                val dividerRight = rightmostChild.right
                mVerticalDivider.setBounds(dividerLeft, dividerTop, dividerRight, dividerBottom )
                mVerticalDivider.draw(canvas)
                Log.e("mytag","called view")
            }else
            {
                Log.e("mytag","i $i")
                Log.e("mytag","leftmostchild ${i * mNumColumns}")
                Log.e("mytag","rightmostchild $rightmostChildIndex")
            }

        }
    }

}