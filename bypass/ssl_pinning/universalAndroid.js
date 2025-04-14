
Java.perform(function () {
    var targetClass = Java.use('j7.e');
    targetClass.b.implementation = function () {
        console.log('[*] Método b() chamado!');
        var result = this.b();
        console.log('[*] Retorno:', result);
        return result;
    };
});

