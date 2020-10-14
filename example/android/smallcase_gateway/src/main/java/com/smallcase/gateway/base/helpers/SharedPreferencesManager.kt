package com.smallcase.gateway.base.helpers

import android.content.Context
import android.content.SharedPreferences
/**
 * Wrapper classes for interacting with shared preferences
 * privateMode :- to set privacy status of the preferences
 * */

class SharedPreferencesManager(context: Context, name: String, privateMode: Boolean) {

    val pref: SharedPreferences = context.applicationContext.getSharedPreferences(name, if (privateMode) { 0 } else { 1 })
    val prefEditor: SharedPreferences.Editor = pref.edit()

    fun put(key: String, value: Any) {
        when (value) {
            is String -> prefEditor.putString(key, value)
            is Float -> prefEditor.putFloat(key, value)
            is Int -> prefEditor.putInt(key, value)
            is Boolean -> prefEditor.putBoolean(key, value)
            is Long -> prefEditor.putLong(key, value)
        }
        prefEditor.apply()
    }
    fun putAll(map: HashMap<String, Any>) {
        map.iterator().forEach {
            put(it.key, it.value)
        }
    }
    fun putString(key: String, value: String) {
        put(key, value)
    }
    fun putLong(key: String, value: Long) {
        put(key, value)
    }
    fun putInt(key: String, value: Int) {
        put(key, value)
    }
    fun putFloat(key: String, value: Float) {
        put(key, value)
    }
    fun putBoolean(key: String, value: Boolean) {
        put(key, value)
    }

    fun getString(key: String): String {
        return pref.getString(key, "")!!
    }
    fun getInt(key: String): Int {
        return pref.getInt(key, -1)
    }
    fun getFloat(key: String): Float {
        return pref.getFloat(key, 0.0f)
    }
    fun getLong(key: String): Long {
        return pref.getLong(key, 0)
    }
    fun getBoolean(key: String): Boolean {
        return pref.getBoolean(key, false)
    }

    fun getString(key: String, defaultValue: String): String {
        return pref.getString(key, defaultValue)!!
    }
    fun getInt(key: String, defaultValue: Int): Int {
        return pref.getInt(key, defaultValue)
    }
    fun getFloat(key: String, defaultValue: Float): Float {
        return pref.getFloat(key, defaultValue)
    }
    fun getLong(key: String, defaultValue: Long): Long {
        return pref.getLong(key, defaultValue)
    }
    fun getBoolean(key: String, defaultValue: Boolean): Boolean {
        return pref.getBoolean(key, defaultValue)
    }

    fun forceCommit() {
        prefEditor.commit()
    }
    fun forceApply() {
        prefEditor.apply()
    }
    fun forceClear() {
        prefEditor.clear()
    }
}
