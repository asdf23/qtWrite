#ifndef FILEOPERATIONS_H
#define FILEOPERATIONS_H

#include <QObject>

class FileOperations : public QObject
{
	Q_OBJECT
	public:
		explicit FileOperations(QObject *parent = 0);
		Q_INVOKABLE void printMessage(QString txt);
		Q_INVOKABLE void saveDataToFile(QString txt1, QString txt2);
		Q_INVOKABLE void saveGlyphs(QString txt1, QString txt2);
		Q_INVOKABLE void saveSVG(QString txt);
		Q_INVOKABLE QString loadDataFromFile();
		Q_INVOKABLE QString loadLetter(QString txt);

	signals:
	public slots:

};

#endif